# TODO - actually make this good. and like do stuff.

class_name MainMenu
extends Control

@export var overworld_scene_path: String

func _on_new_game_pressed() -> void:
	SceneLoader.load_scene(overworld_scene_path)


func _on_load_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().quit()
