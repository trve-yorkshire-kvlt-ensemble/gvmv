class_name CandleData
extends Resource

@export var name: String = "Unknown Candle"
@export var color: Color = Color.RED
@export var base_magic: GameEnums.MagicEffect = GameEnums.MagicEffect.FIRE
@export var texture: Texture2D

# TODO: should probs move these to the candle resource ig!

func get_palette() -> Texture2D:
	match base_magic:
		GameEnums.MagicEffect.FIRE:
			return preload("res://assets/candle_magick/palettes/candle_red.PNG")
		GameEnums.MagicEffect.ICE:
			return preload("res://assets/candle_magick/palettes/candle_blue.PNG")
		GameEnums.MagicEffect.ELECTRIC:
			return preload("res://assets/candle_magick/palettes/candle_orange.PNG")
		GameEnums.MagicEffect.SLIME:
			return preload("res://assets/candle_magick/palettes/candle_green.PNG")
		GameEnums.MagicEffect.MIST:
			return preload("res://assets/candle_magick/palettes/candle_grey.PNG")
		GameEnums.MagicEffect.POISON:
			return preload("res://assets/candle_magick/palettes/candle_khaki.PNG")
		GameEnums.MagicEffect.HEX:
			return preload("res://assets/candle_magick/palettes/candle_purple.PNG")
		GameEnums.MagicEffect.GLITCH:
			return preload("res://assets/candle_magick/palettes/candle_teal.PNG")
	return null

func get_colour() -> Color:
	match base_magic:
		GameEnums.MagicEffect.FIRE:
			return Color("bc001dff") 
		GameEnums.MagicEffect.ICE:
			return Color("4e99e9ff") 
		GameEnums.MagicEffect.ELECTRIC:
			return Color("cc842aff") 
		GameEnums.MagicEffect.SLIME:
			return Color("57af23ff") 
		GameEnums.MagicEffect.MIST:
			return Color("949793ff") 
		GameEnums.MagicEffect.POISON:
			return Color("648052ff") 
		GameEnums.MagicEffect.HEX:
			return Color("a678f4ff")
		GameEnums.MagicEffect.GLITCH:
			return Color("21aab2ff") 
	return Color.WHITE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
