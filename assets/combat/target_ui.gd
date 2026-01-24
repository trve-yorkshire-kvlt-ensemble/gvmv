extends Panel

@onready var button_container: VBoxContainer = $TargetButtonContainer
var target_buttons: Array[TargetButton]

#@onready var description_text: RichTextLabel = $Description
@onready var combat_manager: Node = $"../.."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in button_container.get_children():
		#if child is not CombatActionButton:
			#continue
			
		target_buttons.append(child)
		
		child.pressed.connect(_button_pressed.bind(child))
		#child.mouse_entered.connect(_button_entered.bind(child))
		#child.mouse_exited.connect(_button_exited.bind(child))

func set_targets(targets: Array[CombatCharacter]) -> void:
	for i in len(target_buttons):
		if i >= len(targets):
			target_buttons[i].visible = false
			continue
			
		target_buttons[i].visible = true
		target_buttons[i].set_target(targets[i])
		print("assigning target to button: " + str(targets[i].character_name))

func _button_pressed(button: TargetButton) -> void:
	combat_manager.on_target_selected(button.target)

#func _button_entered(button: CombatActionButton) -> void:
	#var ca: CombatAction = button.combat_action
	#description_text.text = "[b]" + ca.display_name + "[/b]\n" + ca.description
#
#func _button_exited(_button: CombatActionButton) -> void:
	#description_text.text = ""
	#
#func _on_pass_turn_button_pressed() -> void:
	#combat_manager.next_turn()
