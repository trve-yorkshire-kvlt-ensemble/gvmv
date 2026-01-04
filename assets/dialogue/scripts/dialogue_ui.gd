class_name DialogueUI
extends CanvasLayer

const UIState = preload("res://assets/globals/game_enums.gd").UIState

@export var dialogue_text_label: Label
@export var character_name_label: Label
@export var character_reveal_speed: float = 0.05  # Time in seconds per character

var current_dialogue: Dialogue
var current_page_index: int = 0
var text_reveal_tween: Tween
var is_text_fully_revealed: bool = false

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
		_kill_reveal_tween()

func _on_dialogue_started(dialogue: Dialogue) -> void:
	# Initialize dialogue UI with the provided dialogue resource
	current_dialogue = dialogue
	current_page_index = 0
	_display_current_page()

func _display_current_page() -> void:
	if current_dialogue and current_page_index < current_dialogue.pages.size():
		var page: DialoguePage = current_dialogue.pages[current_page_index]
		character_name_label.text = current_dialogue.character_name
		is_text_fully_revealed = false
		_reveal_text_sequentially(page.text)


func advance_dialogue() -> void:
	current_page_index += 1
	if current_page_index < current_dialogue.pages.size():
		_display_current_page()
	else:
		_end_dialogue()

func _reveal_text_sequentially(text: String) -> void:
	_kill_reveal_tween()
	dialogue_text_label.text = ""
	var char_count: int = text.length()
	var duration: float = char_count * character_reveal_speed
	
	text_reveal_tween = create_tween()
	text_reveal_tween.set_trans(Tween.TRANS_LINEAR)
	text_reveal_tween.set_ease(Tween.EASE_IN_OUT)
	
	text_reveal_tween.tween_method(
		func(index: int) -> void:
			dialogue_text_label.text = text.substr(0, index),
		0, char_count, duration
	)
	text_reveal_tween.tween_callback(func() -> void:
		is_text_fully_revealed = true
	)

func _kill_reveal_tween() -> void:
	if text_reveal_tween:
		text_reveal_tween.kill()
		text_reveal_tween = null

func _end_dialogue() -> void:
	GameStateManager.change_state(UIState.OVERWORLD)

func _input(event: InputEvent) -> void:
	# Only respond to input if dialogue is active
	if GameStateManager.current_state == UIState.DIALOGUE:
		var should_handle: bool = false
		
		# Check for mouse click
		if event is InputEventMouseButton:
			if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				should_handle = true
		
		# Check for keyboard input
		elif event.is_action_pressed("interact"):  # Space/E keys
			should_handle = true
		
		if should_handle:
			if is_text_fully_revealed:
				# Text is fully shown, advance to next page
				advance_dialogue()
			else:
				# Text is still revealing, skip to end
				_skip_to_end_of_text()
			get_tree().root.set_input_as_handled()  # Consume the input

func _skip_to_end_of_text() -> void:
	_kill_reveal_tween()
	var page: DialoguePage = current_dialogue.pages[current_page_index]
	dialogue_text_label.text = page.text
	is_text_fully_revealed = true
