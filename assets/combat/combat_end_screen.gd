# TODO: change button to load back to overworld/previous scene
class_name CombatEndScreen
extends Panel

@export var debug_mode: bool = false

@onready var header_text: Label = $HeaderText

func set_header_text(text_to_display: String) -> void:
	header_text.text = text_to_display

func _on_ok_button_pressed() -> void:
	if debug_mode:
		SceneLoader.reload_current_scene()
	else:
		# load overworld
		pass