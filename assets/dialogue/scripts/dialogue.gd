class_name Dialogue
extends Resource

@export var character_name: String = ""  # Name of the character speaking
@export var pages: Array[DialoguePage] = []  # Array of DialoguePage resources
@export var options: Array[DialogueOption] = []  # Array of DialogueOption resources