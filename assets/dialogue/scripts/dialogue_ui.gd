class_name DialogueUI
extends CanvasLayer

@export var dialogue_text_label: Label
@export var character_name_label: Label
@export var options_container: VBoxContainer
@export var dynamic_options_container: VBoxContainer
@export var option_button_scene: PackedScene
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
	if new_state == GameEnums.UIState.DIALOGUE:
		visible = true
	else:
		visible = false
		current_dialogue = null
		current_page_index = 0
		_kill_reveal_tween()

func _on_dialogue_started(dialogue: Dialogue) -> void:
	# Initialize dialogue UI with the provided dialogue resource
	options_container.visible = false
	current_dialogue = dialogue
	current_page_index = 0
	_display_current_page()

func _display_current_page() -> void:
	if current_dialogue and current_page_index < current_dialogue.pages.size():
		var page: DialoguePage = current_dialogue.pages[current_page_index]
		character_name_label.text = current_dialogue.character_name
		is_text_fully_revealed = false
		options_container.visible = false
		_reveal_text_sequentially(page.text)


func advance_dialogue() -> void:
	current_page_index += 1
	if current_page_index < current_dialogue.pages.size():
		_display_current_page()
	else:
		end_dialogue()

func end_dialogue() -> void:
	GameStateManager.change_state(GameEnums.UIState.OVERWORLD)

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
		if _is_on_last_page():
			_show_options()
	)

func _kill_reveal_tween() -> void:
	if text_reveal_tween:
		text_reveal_tween.kill()
		text_reveal_tween = null

func _input(event: InputEvent) -> void:
	# Only respond to input if dialogue is active
	if GameStateManager.current_state == GameEnums.UIState.DIALOGUE:
		var should_handle: bool = false
		var is_interact_action: bool = false
		
		# Check for mouse click
		if event is InputEventMouseButton:
			if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				should_handle = true
		
		# Check for keyboard input
		elif event.is_action_pressed("interact"):  # Space/E keys
			should_handle = true
			is_interact_action = true
		
		if should_handle:
			# Don't handle interact action if options are visible (let buttons handle it)
			if options_container.visible:
				if is_interact_action:
					get_tree().root.set_input_as_handled()  # Consume interact to prevent restart
				return
			
			if is_text_fully_revealed:
				# Text is fully shown, only advance if not on last page
				if not _is_on_last_page():
					advance_dialogue()
				# If on last page, do nothing (options will be shown)
			else:
				# Text is still revealing, skip to end
				_skip_to_end_of_text()
			get_tree().root.set_input_as_handled()  # Consume the input

func _skip_to_end_of_text() -> void:
	_kill_reveal_tween()
	var page: DialoguePage = current_dialogue.pages[current_page_index]
	dialogue_text_label.text = page.text
	is_text_fully_revealed = true
	if _is_on_last_page():
		_show_options()

func _is_on_last_page() -> bool:
	return current_dialogue and current_page_index == current_dialogue.pages.size() - 1

func _clear_options() -> void:
	for child in dynamic_options_container.get_children():
		child.queue_free()

func _show_options() -> void:
	_clear_options()
	if current_dialogue:
		for option in current_dialogue.options:
			if not option.can_select_option(GlobalDataManager.player_data):
				continue  # Skip options the player can't select
			var button: Button = option_button_scene.instantiate()
			button.text = option.text
			# Bind the option to the signal connection to ensure proper capture
			button.pressed.connect(_on_option_selected.bindv([option]))
			dynamic_options_container.add_child(button)
		options_container.visible = true

func _on_option_selected(option: DialogueOption) -> void:
	if option.next_dialogue:
		_on_dialogue_started(option.next_dialogue)
	else:
		end_dialogue()
