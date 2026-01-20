# TODO: initiative/speed to determine order of turns
# TODO: expand for multiple characters on each team
# TODO: make the AI not shit
# TODO: how do we load this from overworld when we initiate an encounter?
# TODO: add some combat end victory/defeat music

extends Node2D

# characters
@onready var player_character: CombatCharacter = $PlayerCharacter
@onready var ai_character: CombatCharacter = $AICharacter
var current_character: CombatCharacter

# UI
@onready var player_ui: Panel = $CanvasLayer/CombatActionsUI
@onready var enemy_ui: Panel = $CanvasLayer/EnemyUI
@onready var enemy_move_text: Label = $CanvasLayer/EnemyUI/EnemyMoveText
@onready var end_screen: Panel = $CanvasLayer/CombatEndScreen
@onready var stats_text: Label = $CanvasLayer/CombatEndScreen/StatsText
@onready var type_ui: Panel = $CanvasLayer/TypeUI

# status
var game_over: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# connect signals
	player_character.OnTakeDamage.connect(_on_player_take_damage)
	ai_character.OnTakeDamage.connect(_on_ai_take_damage)
	# hide end screen if visible
	end_screen.visible = false
	# call turn function
	next_turn()

func _on_player_take_damage(health: int) -> void:
	if health <= 0:
		end_combat(ai_character) # ai wins
	
func _on_ai_take_damage(health: int) -> void:
	if health <= 0:
		end_combat(player_character) # player wins

func end_combat(winner: CombatCharacter) -> void:
	# set end screen ui
	type_ui.visible = false
	enemy_ui.visible = false
	end_screen.visible = true
	# stop game loop
	game_over = true
	if winner == player_character:
		# show XP and loot screen
		stats_text.visible = true
		end_screen.set_header_text(player_character.display_name + " has defeated " + ai_character.display_name)
	else:
		stats_text.visible = false
		end_screen.set_header_text("YOU HAVE BEEN DEFEATED!")

func next_turn() -> void:
	if game_over:
		return
	
	# end previous turn
	if current_character != null:
		current_character.end_turn()
	
	# hide type ui if visible
	type_ui.visible = false
	# choose next character
	if current_character == null or current_character == ai_character:
		# change this so that if character is null (i.e. at the start of the scene)
		# then choose character with highest speed/initiative
		# (so some kind of routine that chooses turn order or smth)
		current_character = player_character
	else:
		current_character = ai_character
	
	# begin turn - this basically just sets the scale
	# can maybe simplify this a bit?
	current_character.begin_turn()
	
	if current_character.is_player: # run this if it's the player's turn
		# disable AI UI if still active
		enemy_ui.visible = false
		# enable and set player UI
		player_ui.visible = true
		player_ui.set_combat_actions(player_character.combat_actions)
	else: # run this if it's the AI's turn
		# disable player UI if still active
		player_ui.visible = false
		# generate a wait time 
		await get_tree().create_timer(0.5).timeout
		var action_to_cast: CombatAction = ai_decide_combat_action()
		enemy_move_text.text = "Thy enemy has used " + action_to_cast.display_name
		# enable AI UI
		enemy_ui.visible = true
		ai_character.cast_combat_action(action_to_cast, player_character)
		# generate a wait time
		await get_tree().create_timer(0.5).timeout
		# restart loop
		next_turn()
	
func player_cast_combat_action(action: CombatAction) -> void:
	# handle for if we get sent here on the AI's turn by mistake
	# I actually think this can't happen so we could maybe lose this
	# But I'm a bit nervous about that as I clearly put it here for a reason T_T
	if player_character != current_character:
		return
	player_character.cast_combat_action(action, ai_character)
	# disable player UI
	player_ui.visible = false
	# create a wait time
	await get_tree().create_timer(0.5).timeout
	# restart loop
	next_turn()

func ai_decide_combat_action() -> CombatAction:
	# handle for if we get sent here on the player's turn by mistake
	# see above... not sure we really need this but scared to take it out
	if ai_character != current_character:
		return null
		
	var ai: CombatCharacter = ai_character # shortnaming
	var player: CombatCharacter = player_character
	var actions: Array[CombatAction] = ai.combat_actions
	var weights: Array[int] = []
	var total_weight = 0
	var ai_health_perc: float = float(ai.current_health) / float(ai.max_health)
	
	# this is basically not a very good way of doing the AI
	# I just copied this from a beginner tutorial
	# Think we can make this way more fun and chaotique :)
	for action in actions:
		var weight: int = action.base_weight
		if player.current_health <= action.base_melee_damage:
			weight *= 3
		if action.heal_amount >0:
			weight *= 1 + (1 - ai_health_perc)
		weights.append(weight)
		total_weight += weight
		
	
	var cumulative_weight = 0
	var rand_weight = randi_range(0, total_weight)
	
	for i in len(actions):
		cumulative_weight += weights[i]
		if rand_weight < cumulative_weight:
			return actions[i]
			
	return null
