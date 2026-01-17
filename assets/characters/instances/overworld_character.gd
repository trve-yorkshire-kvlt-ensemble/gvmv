class_name OverworldCharacter
extends Node2D

@export var character_data: CharacterData
# todo - add more overworld-specific properties like movement patterns, dialogues, etc.
# also merchant inventory if applicable

@onready var character_dialogue: CharacterDialogue = $CharacterDialogue

func _ready() -> void:
	if character_data:
		$Sprite2D.texture = character_data.sprite
	else:
		push_error("OverworldCharacter data not assigned")

func open_trade() -> void:
	# Merchant logic—uses character_data
	pass

func start_dialogue() -> void:
	if character_dialogue:
		character_dialogue.start_conversation()
	else:
		push_error("CharacterDialogue not found")

func start_combat() -> CombatCharacter:
	# Spawn combat version when needed
	var combatant: CombatCharacter = CombatCharacter.new()
	combatant.character_data = character_data
	return combatant
