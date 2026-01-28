# TODO: expand for multiple characters on each team
## okay... i started with this. then i got into the target selection stuff and got a bit lost
## think i need to go through my logic again bit by bit as the target buttons don't do anything
## and also they don't seem to be dyanamically appearing and i'm not sure why...

# TODO: need to think about target types - e.g. we may want to heal an enemy (but would like to defaul to allies)
# some actions may not work on dead enemies/allies so we would want to remove that option
# but for now just getting the logic working

# TODO: make the AI not shit
# TODO: how do we load this from overworld when we initiate an encounter?
# TODO: add some combat end victory/defeat music

# TODO: mana????

# TODO: ai targeting is currently just random
# I think it might be nice to get the AI decision making logic from the character data somehow?
# so that bosses etc can have unique logic

extends Node2D

# characters
# old - from single player combat
#@onready var player_character: CombatCharacter = $PlayerCharacter
#@onready var ai_character: CombatCharacter = $AICharacter
#var current_character: CombatCharacter

# new - for party combat
@onready var player_party: Array[CombatCharacter] = []
@onready var enemy_party: Array[CombatCharacter] = []
var current_character: CombatCharacter

# putting this in as a placeholder before I add target selection stuff
@onready var player_character: CombatCharacter = $PlayerParty/PlayerCharacterA
@onready var ai_character: CombatCharacter = $EnemyParty/AICharacterA

var turn_queue: Array[CombatCharacter] = []

var current_turn_index := 0

# UI
@onready var player_ui: Panel = $CanvasLayer/CombatActionsUI
@onready var target_ui: Panel = $CanvasLayer/TargetUI
@onready var enemy_ui: Panel = $CanvasLayer/EnemyUI
@onready var enemy_move_text: Label = $CanvasLayer/EnemyUI/EnemyMoveText
@onready var end_screen: Panel = $CanvasLayer/CombatEndScreen
@onready var stats_text: Label = $CanvasLayer/CombatEndScreen/StatsText
@onready var type_ui: Panel = $CanvasLayer/TypeUI

# status
var game_over: bool = false

#enum CombatState {
	#IDLE,
	#PLAYER_CHOOSE_ACTION,
	#PLAYER_CHOOSE_TARGET,
	#RESOLVING_ACTION,
	#AI_TURN
#}

#var state: CombatState = CombatState.IDLE
var pending_action: CombatAction
var pending_actor: CombatCharacter

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# load parties
	for character in $PlayerParty.get_children():
		player_party.append(character as CombatCharacter)
		character.OnDied.connect(_on_player_died)
	print("player party = " + str(player_party))
	for character in $EnemyParty.get_children():
		enemy_party.append(character as CombatCharacter)
		character.OnDied.connect(_on_enemy_died)
	print("player party = " + str(enemy_party))
	# hide end screen if visible
	end_screen.visible = false
	# call turn function
	next_turn()

func build_turn_queue():
	# clear queue
	turn_queue.clear()
	
	# set list of combatants
	var all_combatants: Array[CombatCharacter] = []
	all_combatants.append_array(player_party)
	all_combatants.append_array(enemy_party)
	
	# remove dead characters
	all_combatants = all_combatants.filter(func(c): return c.current_health > 0)
	
	# sort by speed (fastest first)
	all_combatants.sort_custom(func(a, b):
		return a.speed > b.speed
		)
	
	# now populate the turn queue
	turn_queue = all_combatants
	print("turn queue: "+str(turn_queue))
	# and reset turn index
	current_turn_index = 0

# these were the old funcs to check if one character was dead
# I'm updating this to check the party instead
#func _on_player_take_damage(health: int) -> void:
	#if health <= 0:
		#end_combat(ai_character) # ai wins
	#
#func _on_ai_take_damage(health: int) -> void:
	#if health <= 0:
		#end_combat(player_character) # player wins
		
func _on_player_died(dead_character: CombatCharacter) -> void:
	print("oh no, " + dead_character.character_name + " has died :(")
	# rebuild turn queue (handles for dead characters)
	# turn_queue.erase(dead_character)
	build_turn_queue()
	# Check if all players are dead (no alive members left)
	if len(get_alive_players()) <= 0:
		end_combat("enemies")  # AI wins

func _on_enemy_died(dead_character: CombatCharacter) -> void:
	print("you have killed " + dead_character.character_name + "!")
	# rebuild turn queue (handles for dead characters)
	build_turn_queue()
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
	
	# populate turn queue if it's empty
	# hmmm... I think I want to check the turn queue evey round
	if turn_queue.is_empty():
		build_turn_queue()
	
	print("the turn index is " + str(current_turn_index))
	current_character = turn_queue[current_turn_index]
	print("it is " + current_character.character_name +"'s turn")
	# skip dead characters :(
	print(current_character.name +"'s health = "+str(current_character.current_health))
	if current_character.current_health <= 0:
		advance_turn()
		return
		
	current_character.begin_turn()
	
	if current_character.is_player:
		# so chat gave me this vague start_player_turn
		# for now I'm going to stick with my old logic just to get smth working
		start_player_turn(current_character)
		## disable AI UI if still active - probs want to change this to being handled by signals i guess
		#enemy_ui.visible = false
		## enable and set player UI
		#player_ui.visible = true
		#print("it is the player's turn, their combat actions are: " + str(current_character.combat_actions))
		#player_ui.set_combat_actions(current_character.combat_actions)
	else: # run this if it's the AI's turn
		# chat gave me this but sticking with old logic for now
		await start_ai_turn(current_character)
		# disable player UI if still active
		#player_ui.visible = false
		## generate a wait time 
		#await get_tree().create_timer(0.5).timeout
		#var action_to_cast: CombatAction = ai_decide_combat_action()
		#enemy_move_text.text = "Thy enemy has used " + action_to_cast.display_name
		## enable AI UI
		#enemy_ui.visible = true
		#current_character.cast_combat_action(action_to_cast, [player_character])
		## generate a wait time
		#await get_tree().create_timer(0.5).timeout
		## restart loop
		#advance_turn()

func advance_turn() -> void:
	current_turn_index += 1
	if current_turn_index >= turn_queue.size():
		current_turn_index = 0
		# I think this might be where I want to re-build the turn queue!
	next_turn()

func start_player_turn(character: CombatCharacter) -> void:
	#state = CombatState.PLAYER_CHOOSE_ACTION
	pending_actor = character # not sure how this passes on to resolve action
	enemy_ui.visible = false
	player_ui.visible = true
	player_ui.set_combat_actions(character.combat_actions)

func start_ai_turn(current_character: CombatCharacter):
		# disable player UI if still active
		player_ui.visible = false
		pending_actor = current_character
		# generate a wait time 
		await get_tree().create_timer(0.5).timeout
		var action_to_cast: CombatAction = ai_decide_combat_action()
		ai_decide_target(action_to_cast)
		# TODO: send a signal and move the UI stuff elsewhere
		#enemy_move_text.text = "Thy enemy has used " + action_to_cast.display_name
		# enable AI UI
		#enemy_ui.visible = true
		#current_character.cast_combat_action(action_to_cast, [player_character])
		# generate a wait time
		# await get_tree().create_timer(0.5).timeout
		# restart loop
		# advance_turn()

func on_player_action_selected(action: CombatAction) -> void:
	pending_action = action
	print("pending action is: " + action.display_name)
	player_ui.visible = false
	print("target type is: " + str(action.target_type))
	match action.target_type:
		
		CombatAction.TargetType.ALL_ENEMIES:
			resolve_action(pending_actor, action, get_alive_enemies())
		
		CombatAction.TargetType.ALL_ALLIES:
			#var alive_players: Array[CombatCharacter] = get_alive_players()
			resolve_action(pending_actor, action, get_alive_players())
		
		CombatAction.TargetType.SINGLE_ENEMY:
			var alive_enemies: Array[CombatCharacter] = get_alive_enemies()
			target_ui.visible = true
			target_ui.set_targets(alive_enemies)
			#resolve_action(pending_actor, action, get_alive_players())
			
		CombatAction.TargetType.SINGLE_ALLY:
			target_ui.visible = true
			target_ui.set_targets(player_party)
			#resolve_action(pending_actor, action, get_alive_players())
		
		#_:
			#state = CombatState.PLAYER_CHOOSE_TARGET
			#show_target_selection(action)

#func show_target_selection(action: CombatAction) -> void:
	#var valid_targets: Array[CombatCharacter]
#
	#if action.target_type == CombatAction.TargetType.SINGLE_ENEMY:
		#valid_targets = get_alive_enemies()
	### not super sure on the logic here... I thnk we need to rethink the target types
	### also no idea what the state stuff is meant to be doing...
	## ok I think it's okay - we only get here if we need to choos
	## so this logic just decides if we need to choose an enemy or an ally
	## tbh I think I don't need to distinguish, I think we want to be able to
	## e.g. cast heal on an enemy
	#else:
		#valid_targets = get_alive_players()
#
	#for c in valid_targets:
		#c.enable_targeting()
		
func ai_decide_target(action: CombatAction) -> void:
	match action.target_type:
		
		CombatAction.TargetType.ALL_ENEMIES:
			# NB if an enemy is targeting all enemies, this needs to 
			# impact player characters (and vice versa)
			resolve_action(pending_actor, action, get_alive_players())
		
		CombatAction.TargetType.ALL_ALLIES:
			#var alive_players = get_alive_players()
			resolve_action(pending_actor, action, get_alive_enemies())
		
		CombatAction.TargetType.SINGLE_ENEMY:
			var alive_targets: Array[CombatCharacter] = get_alive_players()
			var selected_target: Array[CombatCharacter] = [alive_targets[randi_range(0,len(alive_targets)-1)]]
			resolve_action(pending_actor, action, selected_target)
			
		CombatAction.TargetType.SINGLE_ALLY:
			var alive_targets: Array[CombatCharacter] = get_alive_enemies()
			var selected_target: Array[CombatCharacter] = [alive_targets[randi_range(0,len(alive_targets)-1)]]
			resolve_action(pending_actor, action, selected_target)
			#resolve_action(pending_actor, action, get_alive_players())

func on_target_selected(target: CombatCharacter) -> void:
	#clear_targeting()
	var selected_target: Array[CombatCharacter] = []
	selected_target.append(target)
	resolve_action(pending_actor, pending_action, selected_target)

func get_alive_players() -> Array[CombatCharacter]:
	return player_party.filter(func(c): return c.current_health > 0)

func get_alive_enemies() -> Array[CombatCharacter]:
	return enemy_party.filter(func(c): return c.current_health > 0)

#func get_alive_allies() -> Array[CombatCharacter]:
	#return pending_actor.is_player \
		#? get_alive_players() \
		#: get_alive_enemies()


func resolve_action(actor: CombatCharacter, action: CombatAction, targets: Array[CombatCharacter]) -> void:
	#state = CombatState.RESOLVING_ACTION
	print("resolving action... action = "+action.display_name+" and target(s) = " + str(targets) )
	actor.cast_combat_action(action, targets)
	await get_tree().create_timer(0.5).timeout
	target_ui.visible = false
	advance_turn()

#func player_cast_combat_action(action: CombatAction) -> void:
	#print("player casting " + action.display_name + " against " + ai_character.name)
	#player_character.cast_combat_action(action, [ai_character])
	## disable player UI
	#player_ui.visible = false
	## create a wait time
	#await get_tree().create_timer(0.5).timeout
	## restart loop
	#advance_turn()

func ai_decide_combat_action() -> CombatAction:	
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
