class_name CandleSlot
extends TextureButton

@export var current_candle : CandleData = null

@onready var candle_sprite = $CandleSprite

signal slot_clicked(node_ref) # define the signal

func _pressed() -> void:
	slot_clicked.emit(self) # signal that this slot has been clicked
	
func set_candle(data: CandleData):
	current_candle = data
	candle_sprite.texture = data.texture
	candle_sprite.show()
	# TODO play a sound effect or smth


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
