# TODO: initiative/speed to determine order of turns
# TODO: expand for multiple characters on each team
# TODO: make the AI not shit
# TODO: how do we load this from overworld when we initiate an encounter?
# TODO: add some combat end victory/defeat music

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
@onready var enemy_ui: Panel = $CanvasLayer/EnemyUI
@onready var enemy_move_text: Label = $CanvasLayer/EnemyUI/EnemyMoveText
@onready var end_screen: Panel = $CanvasLayer/CombatEndScreen
@onready var stats_text: Label = $CanvasLayer/CombatEndScreen/StatsText
@onready var type_ui: Panel = $CanvasLayer/TypeUI

# status
var game_over: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# connect signals - these are the old 1v1 signals so I am replacing them...
	#player_character.OnTakeDamage.connect(_on_player_take_damage)
	#ai_character.OnTakeDamage.connect(_on_ai_take_damage)
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
	# chat suggested something like this to dynamically position players, but i'm not sure where to put it...
	#character.global_position = base_pos + Vector2(party_index * spacing, 0)
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
	print("player " + dead_character.character_name + " has died :(")
	# rebuild turn queue (handles for dead characters)
	# turn_queue.erase(dead_character)
	build_turn_queue()
	# Check if all players are dead (no alive members left)
	if player_party.count(func(c): return c.health > 0) == 0:
		end_combat("enemies")  # AI wins

func _on_enemy_died(dead_character: CombatCharacter) -> void:
	print("player " + dead_character.character_name + " has died :(")
	# rebuild turn queue (handles for dead characters)
	build_turn_queue()
	# Check if all players are dead (no alive members left)
	if enemy_party.count(func(c): return c.health > 0) == 0:
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
	# hmmm... I think I want to check the turn qwueue evey round
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
		#start_player_turn(current_character)
		# disable AI UI if still active - probs want to change this to being handled by signals i guess
		enemy_ui.visible = false
		# enable and set player UI
		player_ui.visible = true
		print("it is the player's turn, their combat actions are: " + str(current_character.combat_actions))
		player_ui.set_combat_actions(current_character.combat_actions)
	else: # run this if it's the AI's turn
		# chat gave me this but sticking with old logic for now
		#await start_ai_turn(current_character)
		# disable player UI if still active
		player_ui.visible = false
		# generate a wait time 
		await get_tree().create_timer(0.5).timeout
		var action_to_cast: CombatAction = ai_decide_combat_action()
		enemy_move_text.text = "Thy enemy has used " + action_to_cast.display_name
		# enable AI UI
		enemy_ui.visible = true
		current_character.cast_combat_action(action_to_cast, [player_character])
		# generate a wait time
		await get_tree().create_timer(0.5).timeout
		# restart loop
		advance_turn()

func advance_turn() -> void:
	current_turn_index += 1
	if current_turn_index >= turn_queue.size():
		current_turn_index = 0
		# I think this is where I want to re-build the turn queue!
	next_turn()


	
	##### old next turn from single party combat #####
	# end previous turn
	#if current_character != null:
		#current_character.end_turn()
	#
	## hide type ui if visible
	#type_ui.visible = false
	## choose next character
	#if current_character == null or current_character == ai_character:
		## change this so that if character is null (i.e. at the start of the scene)
		## then choose character with highest speed/initiative
		## (so some kind of routine that chooses turn order or smth)
		#current_character = player_character
	#else:
		#current_character = ai_character
	#
	## begin turn - this basically just sets the scale
	## can maybe simplify this a bit?
	#current_character.begin_turn()
	#
	#if current_character.is_player: # run this if it's the player's turn
		## disable AI UI if still active
		#enemy_ui.visible = false
		## enable and set player UI
		#player_ui.visible = true
		#player_ui.set_combat_actions(player_character.combat_actions)
	#else: # run this if it's the AI's turn
		## disable player UI if still active
		#player_ui.visible = false
		## generate a wait time 
		#await get_tree().create_timer(0.5).timeout
		#var action_to_cast: CombatAction = ai_decide_combat_action()
		#enemy_move_text.text = "Thy enemy has used " + action_to_cast.display_name
		## enable AI UI
		#enemy_ui.visible = true
		#ai_character.cast_combat_action(action_to_cast, player_character)
		## generate a wait time
		#await get_tree().create_timer(0.5).timeout
		## restart loop
		#next_turn()
	
func player_cast_combat_action(action: CombatAction) -> void:
	# handle for if we get sent here on the AI's turn by mistake
	# I actually think this can't happen so we could maybe lose this
	# But I'm a bit nervous about that as I clearly put it here for a reason T_T
	#if player_character != current_character:
		#return
	print("player casting " + action.display_name + " against " + ai_character.name)
	player_character.cast_combat_action(action, [ai_character])
	# disable player UI
	player_ui.visible = false
	# create a wait time
	await get_tree().create_timer(0.5).timeout
	# restart loop
	advance_turn()

func ai_decide_combat_action() -> CombatAction:
	# handle for if we get sent here on the player's turn by mistake
	# see above... not sure we really need this but scared to take it out
	#if ai_character != current_character:
		#return null
		
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
