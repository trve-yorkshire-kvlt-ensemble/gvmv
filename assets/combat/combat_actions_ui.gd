extends Panel

@onready var button_container = $ButtonContainer
var ca_buttons: Array[CombatActionButton]

@onready var description_text: RichTextLabel = $Description
@onready var combat_manager = $"../.."


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in button_container.get_children():
		if child is not CombatActionButton:
			continue
			
		ca_buttons.append(child)
		
		child.pressed.connect(_button_pressed.bind(child))
		
		child.pressed.connect(_button_pressed.bind(child))
		child.mouse_entered.connect(_button_entered.bind(child))
		child.mouse_exited.connect(_button_exited.bind(child))

func set_combat_actions(actions: Array[CombatAction]):
	for i in len(ca_buttons):
		if i >= len(actions):
			ca_buttons[i].visible = false
			continue
			
		ca_buttons[i].visible = true
		ca_buttons[i].set_combat_action(actions[i])

func _button_pressed(button: CombatActionButton):
	print("pressed")
	combat_manager.player_cast_combat_action(button.combat_action)

func _button_entered(button: CombatActionButton):
	print("entered")
	var ca = button.combat_action
	description_text.text = "[b]" + ca.display_name + "[/b]\n" + ca.description
	

func _button_exited(button: CombatActionButton):
	print("exited")
	description_text.text = ""
	
func _on_pass_turn_button_pressed() -> void:
	combat_manager.next_turn()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
