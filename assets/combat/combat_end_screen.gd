# TODO: change button to load back to overworld/previous scene

extends Panel

@onready var header_text: Label = $HeaderText

func set_header_text(text_to_display: String) -> void:
	header_text.text = text_to_display

func _on_ok_button_pressed() -> void:
	get_tree().reload_current_scene() # replace this with overworld or whatever
	pass # Replace with function body.
