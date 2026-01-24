extends Button
class_name TargetButton

var target: CombatCharacter

func set_target(t: CombatCharacter) -> void:
	target = t
	text = target.character_name
