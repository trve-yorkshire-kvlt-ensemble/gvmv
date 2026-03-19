# TODO: change button to load back to overworld/previous scene
class_name CombatEndScreen
extends Panel

@export var debug_mode: bool = false

@onready var header_text: Label = $HeaderText
@onready var stats_text: Label = $StatsText

func set_header_text(text_to_display: String) -> void:
	header_text.text = text_to_display

func set_stats_text(xp: int, gold: int) -> void:
	stats_text.text = "XP: " + str(xp) + "\nGold: " + str(gold) + "gp"

func _on_ok_button_pressed() -> void:
	if debug_mode:
		SceneLoader.reload_current_scene()
	else:
		# load overworld
		pass