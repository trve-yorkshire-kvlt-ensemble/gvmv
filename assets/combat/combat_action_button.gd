extends Button
class_name CombatActionButton

var combat_action: CombatAction

func set_combat_action(ca: CombatAction):
	combat_action = ca
	text = ca.display_name


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
