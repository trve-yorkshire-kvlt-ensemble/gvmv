class_name DialogueUI
extends CanvasLayer

const UIState = preload("res://assets/globals/game_enums.gd").UIState

@export var dialogue_text_label: Label
@export var character_name_label: Label

var current_dialogue: Dialogue
var current_page_index: int = 0

func _ready() -> void:
	EventBus.ui_state_changed.connect(_on_ui_state_changed)
	EventBus.dialogue_started.connect(_on_dialogue_started)
	visible = false

func _on_ui_state_changed(new_state: int) -> void:
	if new_state == UIState.DIALOGUE:
		visible = true
	else:
		visible = false
		current_dialogue = null
		current_page_index = 0

func _on_dialogue_started(dialogue: Dialogue) -> void:
	# Initialize dialogue UI with the provided dialogue resource
	current_dialogue = dialogue
	current_page_index = 0
	_display_current_page()

func _display_current_page() -> void:
	if current_dialogue and current_page_index < current_dialogue.pages.size():
		var page: DialoguePage = current_dialogue.pages[current_page_index]
		character_name_label.text = current_dialogue.character_name
		dialogue_text_label.text = page.text


func advance_dialogue() -> void:
	current_page_index += 1
	if current_page_index < current_dialogue.pages.size():
		_display_current_page()
	else:
		_end_dialogue()

func _end_dialogue() -> void:
	GameStateManager.change_state(UIState.OVERWORLD)

func _input(event: InputEvent) -> void:
	# Only advance if dialogue is active
	if GameStateManager.current_state == UIState.DIALOGUE:
		var should_advance: bool = false
		
		# Check for mouse click
		if event is InputEventMouseButton:
			if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				should_advance = true
		
		# Check for keyboard input
		elif event.is_action_pressed("interact"):  # Space/E keys
			should_advance = true
		
		if should_advance:
			advance_dialogue()
			get_tree().root.set_input_as_handled()  # Consume the input
