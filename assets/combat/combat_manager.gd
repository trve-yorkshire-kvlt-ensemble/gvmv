# TODO: initiative/speed to determine order of turns
# TODO: expand for multiple characters on each team
# TODO: make the AI not shit

extends Node2D

@onready var player_character: CombatCharacter = $PlayerCharacter
@onready var ai_character: CombatCharacter = $AICharacter
var current_character: CombatCharacter

@onready var player_ui = $CanvasLayer/CombatActionsUI
@onready var enemy_ui = $CanvasLayer/EnemyUI
@onready var enemy_move_text = $CanvasLayer/EnemyUI/EnemyMoveText

var game_over: bool = false
@onready var end_screen = $CanvasLayer/CombatEndScreen
@onready var stats_text = $CanvasLayer/CombatEndScreen/StatsText

@onready var type_ui = $CanvasLayer/TypeUI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_character.OnTakeDamage.connect(_on_player_take_damage)
	ai_character.OnTakeDamage.connect(_on_ai_take_damage)
	
	end_screen.visible = false
	
	next_turn()

func _on_player_take_damage(health: int):
	if health <= 0:
		end_combat(ai_character)
	
func _on_ai_take_damage(health: int):
	if health <= 0:
		end_combat(player_character)

func end_combat(winner: CombatCharacter):
	type_ui.visible = false
	enemy_ui.visible = false
	game_over = true
	end_screen.visible = true
	if winner == player_character:
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
		# force inactive state
		ai_character.end_turn()
	else:
		current_character = ai_character
		
	current_character.begin_turn()
	
	if current_character.is_player:
		# disable AI UI if still active
		enemy_ui.visible = false
		# enable and set player UI
		player_ui.visible = true
		player_ui.set_combat_actions(player_character.combat_actions)
		#await get_tree().create_timer(0.5).timeout
		#next_turn()
	else:
		# disable player UI if still active
		player_ui.visible = false
		# generate a wait time 
		await get_tree().create_timer(0.5).timeout
		var action_to_cast: CombatAction = ai_decide_combat_action()
		if action_to_cast == null:
			print("no action chosen")
		else:
			print("chosen action: " + action_to_cast.display_name)
		enemy_move_text.text = "Thy enemy has used " + action_to_cast.display_name
		# enable AI UI - so like maybe just the name of the action the AI takes
		enemy_ui.visible = true
		ai_character.cast_combat_action(action_to_cast, player_character)
		await get_tree().create_timer(0.5).timeout
		next_turn()
	
func player_cast_combat_action(action: CombatAction):
	if player_character != current_character:
		return
	
	player_character.cast_combat_action(action, ai_character)
	# disable player UI
	player_ui.visible = false
	await get_tree().create_timer(0.5).timeout
	next_turn()

func ai_decide_combat_action() -> CombatAction:
	if ai_character != current_character:
		return null
		
	var ai: CombatCharacter = ai_character
	var player: CombatCharacter = player_character
	var actions: Array[CombatAction] = ai.combat_actions
	var weights: Array[int] = []
	var total_weight = 0
	var ai_health_perc: float = float(ai.current_health) / float(ai.max_health)
	
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
			print(actions[i].display_name)
			return actions[i]
			
	return null
