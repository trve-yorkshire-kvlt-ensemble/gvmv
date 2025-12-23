class_name OverworldCharacter
extends Node2D

@export var character_data: CharacterData
@export var interaction_range: float = 50.0
# todo - add more overworld-specific properties like movement patterns, dialogues, etc.
# also merchant inventory if applicable

func _ready() -> void:
	if character_data:
		$Sprite2D.texture = character_data.sprite
	else:
		push_error("OverworldCharacter data not assigned")

func is_in_range(player_position: Vector2) -> bool:
	return global_position.distance_to(player_position) <= interaction_range

func open_trade() -> void:
	# Merchant logic—uses character_data
	pass

func start_dialogue() -> void:
	# Dialogue logic—uses character_data.name, etc.
	pass

func start_combat() -> CombatCharacter:
	# Spawn combat version when needed
	var combatant: CombatCharacter = CombatCharacter.new()
	combatant.character_data = character_data
	return combatant
