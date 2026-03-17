# GlobalDataManager.gd (autoload)
extends Node

var player_data: PlayerData
var game_data: GameData

func _ready() -> void:
	player_data = load("res://assets/player/player_data.tres")
	player_data.initialize() # Initialize player data (e.g., party members)
	game_data = load("res://assets/globals/game_data.tres")
