extends Button
class_name CombatActionButton

var combat_action: CombatAction

func set_combat_action(ca: CombatAction) -> void:
	combat_action = ca
	text = ca.display_name
