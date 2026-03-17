# TODO: need to think about target types - e.g. we may want to heal an enemy (but would like to defaul to allies)
# some actions may not work on dead enemies/allies so we would want to remove that option
# but for now just getting the logic working

# TODO: how do we load this from overworld when we initiate an encounter?
# TODO: add some combat end victory/defeat music

# TODO: mana???? "attack all" is so OP at the moment - but this could be something that comes from the candle magick?

# TODO: ai move selection and targeting is currently just random
# I think it might be nice to get the AI decision making logic from the character data somehow?
# so that bosses etc can have unique logic

class_name CombatManager
extends Node2D

# party loading
@export var player_data: PlayerData
@export var combat_character_scene: PackedScene

# characters
var player_party: Array[CombatCharacter] = []
var enemy_party: Array[CombatCharacter] = []
var current_character: CombatCharacter

# turn queue
var turn_queue: Array[CombatCharacter] = []
var current_turn_index := 0
var pending_action: CombatAction # not 100% sure we need this...

# UI
@onready var player_ui: Panel = $CanvasLayer/CombatActionsUI
@onready var target_ui: Panel = $CanvasLayer/TargetUI
@onready var enemy_ui: Panel = $CanvasLayer/EnemyUI
@onready var enemy_move_text: Label = $CanvasLayer/EnemyUI/EnemyMoveText
@onready var end_screen: Panel = $CanvasLayer/CombatEndScreen
@onready var stats_text: Label = $CanvasLayer/CombatEndScreen/StatsText
@onready var type_ui: Panel = $CanvasLayer/TypeUI

# signals
signal OnEnemyAction(combat_action: CombatAction)

# status
var game_over: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# load parties
	for player_character in $PlayerParty.get_children():
		player_party.append(player_character as CombatCharacter)
		player_character.OnDied.connect(_on_player_died)
		player_character.OnTakeDamage.connect(type_ui._type_ui)
	for enemy_character in $EnemyParty.get_children():
		enemy_party.append(enemy_character as CombatCharacter)
		enemy_character.OnDied.connect(_on_enemy_died)
		enemy_character.OnTakeDamage.connect(type_ui._type_ui)
	# hide end screen if visible
	end_screen.visible = false
	# build queue
	build_turn_queue()
	# call turn function
	next_turn()


func build_turn_queue() -> void:
	# clear queue
	turn_queue.clear()
	# set list of combatants
	var all_combatants: Array[CombatCharacter] = []
	all_combatants.append_array(get_alive_players())
	all_combatants.append_array(get_alive_enemies())
	
	# sort by speed (fastest first)
	all_combatants.sort_custom(func(a: CombatCharacter, b: CombatCharacter) -> bool:
		return a.speed > b.speed
		)
	
	# now populate the turn queue
	turn_queue = all_combatants
	# and reset turn index
	current_turn_index = 0
	print("the turn queue is....")
	for combatant in turn_queue:
		print(combatant.character_name)


func _on_player_died(dead_character: CombatCharacter) -> void:
	print("oh no, " + dead_character.character_name + " has died :(")
	# Check if all players are dead (no alive members left)
	if len(get_alive_players()) <= 0:
		end_combat("enemies")  # AI wins


func _on_enemy_died(dead_character: CombatCharacter) -> void:
	print("you have killed " + dead_character.character_name + "!")
	# Check if all players are dead (no alive members left)
	if len(get_alive_enemies()) <= 0:
		end_combat("players")  # AI wins


func end_combat(winner: String) -> void:
	# set end screen ui
	type_ui.visible = false
	enemy_ui.visible = false
	end_screen.visible = true
	# stop game loop
	game_over = true
	if winner == "players":
		# show XP and loot screen
		stats_text.visible = true
		end_screen.set_header_text("You are victorious!")
	else:
		stats_text.visible = false
		end_screen.set_header_text("YOU HAVE BEEN DEFEATED!")


func next_turn() -> void:
	if game_over:
		return
	# set current character based on turn queue
	current_character = turn_queue[current_turn_index]
	# skip dead characters :(
	if not current_character.is_alive():
		advance_turn()
		return
	current_character.begin_turn()
	
	if current_character.is_player:
		start_player_turn(current_character)
	else: # run this if it's the AI's turn
		await start_ai_turn(current_character)


func advance_turn() -> void:
	current_turn_index += 1
	if current_turn_index >= turn_queue.size():
		build_turn_queue() # to account for speed buffs/debuffs
	next_turn()


func start_player_turn(player_character: CombatCharacter) -> void:
	#enemy_ui.visible = false
	player_ui.visible = true
	player_ui.set_combat_actions(player_character.combat_actions)


func start_ai_turn(p_current_character: CombatCharacter) -> void:
		# disable player UI if still active
		player_ui.visible = false
		# generate a wait time 
		await get_tree().create_timer(0.5).timeout
		var action_to_cast: CombatAction = ai_decide_combat_action()
		ai_decide_target(action_to_cast)
		OnEnemyAction.emit(action_to_cast, p_current_character)

func on_player_action_selected(action: CombatAction) -> void:
	pending_action = action
	player_ui.visible = false
	match action.target_type:
		
		CombatAction.TargetType.ALL_ENEMIES:
			resolve_action(current_character, action, get_alive_enemies())
		
		CombatAction.TargetType.ALL_ALLIES:
			#var alive_players: Array[CombatCharacter] = get_alive_players()
			resolve_action(current_character, action, get_alive_players())
		
		CombatAction.TargetType.SINGLE_ENEMY:
			var alive_enemies: Array[CombatCharacter] = get_alive_enemies()
			target_ui.visible = true
			target_ui.set_targets(alive_enemies)
			
		CombatAction.TargetType.SINGLE_ALLY:
			target_ui.visible = true
			target_ui.set_targets(player_party)


func ai_decide_target(action: CombatAction) -> void:
	match action.target_type:
		
		CombatAction.TargetType.ALL_ENEMIES:
			# NB if an enemy is targeting all enemies, this needs to 
			# impact player characters (and vice versa)
			resolve_action(current_character, action, get_alive_players())
		
		CombatAction.TargetType.ALL_ALLIES:
			#var alive_players = get_alive_players()
			resolve_action(current_character, action, get_alive_enemies())
		
		CombatAction.TargetType.SINGLE_ENEMY:
			var alive_targets: Array[CombatCharacter] = get_alive_players()
			var selected_target: Array[CombatCharacter] = [alive_targets[randi_range(0,len(alive_targets)-1)]]
			resolve_action(current_character, action, selected_target)
			
		CombatAction.TargetType.SINGLE_ALLY:
			var alive_targets: Array[CombatCharacter] = get_alive_enemies()
			var selected_target: Array[CombatCharacter] = [alive_targets[randi_range(0,len(alive_targets)-1)]]
			resolve_action(current_character, action, selected_target)


func on_target_selected(target: CombatCharacter) -> void:
	var selected_target: Array[CombatCharacter] = []
	selected_target.append(target)
	resolve_action(current_character, pending_action, selected_target)

func get_alive_players() -> Array[CombatCharacter]:
	return player_party.filter(func(c: CombatCharacter) -> bool: return c.is_alive())

func get_alive_enemies() -> Array[CombatCharacter]:
	return enemy_party.filter(func(c: CombatCharacter) -> bool: return c.is_alive())

func resolve_action(actor: CombatCharacter, action: CombatAction, targets: Array[CombatCharacter]) -> void:
	actor.cast_combat_action(action, targets)
	await get_tree().create_timer(0.5).timeout
	target_ui.visible = false
	advance_turn()


func ai_decide_combat_action() -> CombatAction:	
	#var ai: CombatCharacter = ai_character # shortnaming
	#var player: CombatCharacter = player_character
	var actions: Array[CombatAction] = current_character.combat_actions
	var weights: Array[int] = []
	var total_weight: int = 0
	var ai_health_perc: float = float(current_character.current_health) / float(current_character.max_health)
	
	for action in actions:
		var weight: int = action.base_weight
		if action.heal_amount > 0:
			weight *= 1 + (1 - ai_health_perc)
		weights.append(weight)
		total_weight += weight
	
	var cumulative_weight: int = 0
	var rand_weight: int = randi_range(0, total_weight)
	
	for i in len(actions):
		cumulative_weight += weights[i]
		if rand_weight < cumulative_weight:
			return actions[i]
			
	return null
