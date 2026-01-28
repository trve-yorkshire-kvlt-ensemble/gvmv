extends Panel

@onready var combat_character: CombatCharacter = $"../../PlayerParty/PlayerCharacterA"
@onready var type_match_text: Label = $TypeText

# constants
const MagicEffect = preload("res://assets/globals/game_enums.gd").MagicEffect


func _type_ui(_current_health: int, _amount: int, type: MagicEffect, was_weak:bool, character_name: String) -> void:
	if was_weak:
		self.visible = true
		type_match_text.text = character_name + " is weak against " + MagicEffect.keys()[type]
		await get_tree().create_timer(0.8).timeout
		self.visible = false
