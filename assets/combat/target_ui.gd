extends Panel

@onready var button_container: VBoxContainer = $TargetButtonContainer
var target_buttons: Array[TargetButton]

#@onready var description_text: RichTextLabel = $Description
@onready var combat_manager: Node = $"../.."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in button_container.get_children():
		target_buttons.append(child)
		child.pressed.connect(_button_pressed.bind(child))

func set_targets(targets: Array[CombatCharacter]) -> void:
	for i in len(target_buttons):
		if i >= len(targets):
			target_buttons[i].visible = false
			continue
			
		target_buttons[i].visible = true
		target_buttons[i].set_target(targets[i])

func _button_pressed(button: TargetButton) -> void:
	combat_manager.on_target_selected(button.target)
