# TODO: initiative/speed to determine order of turns
# TODO: expand for multiple characters on each team
# TODO: add animations
# TODO: add sfx
# TODO: add battle music

extends Node2D

@export var player_character: CombatCharacter
@export var ai_character: CombatCharacter
var current_character: CombatCharacter

var game_over: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	next_turn()

	
func next_turn() -> void:
	if game_over:
		return
	if current_character != null:
		current_character.end_turn()
	if current_character == null or current_character == ai_character:
		# change this so that if character is null (i.e. at the start of the scene)
		# then choose character with highest speed/initiative
		# (so some kind of routine that chooses turn order or smth)
		current_character = player_character
	else:
		current_character = ai_character
		
	current_character.begin_turn()
	
	if current_character.is_player:
		pass
		# disable AI UI if still active
		# enable and set player UI
		#await get_tree().create_timer(0.5).timeout
		#next_turn()
	else:
		# disable player UI if still active
		# enable AI UI - so like maybe just the name of the action the AI takes
		# generate a wait time 
		# add animations
		var wait_time: float = randf_range(0.5, 1.5)
		await get_tree().create_timer(wait_time).timeout
		var action_to_cast: CombatAction = ai_decide_combat_action()
		ai_character.cast_combat_action(action_to_cast, player_character)
		await get_tree().create_timer(0.5).timeout
		next_turn()
	
func player_cast_combat_action(action: CombatAction):
	if player_character != current_character:
		return
	
	player_character.cast_combat_action(action, ai_character)
	# disable player UI
	await get_tree().create_timer(0.5).timeout
	next_turn()

func ai_decide_combat_action() -> CombatAction:
	# implement AI decision making here
	return null
