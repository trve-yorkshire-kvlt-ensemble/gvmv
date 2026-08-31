class_name CandleSlot
extends TextureButton

@export var current_candle : CandleData = null

@onready var candle_sprite: Sprite2D = $CandleSprite
@onready var candle_animation: AnimatedSprite2D = $CandleAnimation
@onready var glow_animation: AnimatedSprite2D = $SlotGlow

signal slot_clicked(node_ref) # define the signal

# audio
@onready var audio: AudioStreamPlayer = $SFX
var candle_sfx: AudioStream = preload("res://assets/candle_magick/sfx/tsch.wav")


func _pressed():
	slot_clicked.emit(self) # signal that this slot has been clicked
	
func set_candle(data: CandleData) -> bool:
	current_candle = data
	#candle_sprite.texture = data.texture
	#candle_sprite.show()
	# set candle colour
	var palette = data.get_palette()
	candle_animation.material.set_shader_parameter("palette_tex", palette)
	candle_animation.show()
	_play_audio(candle_sfx)
	candle_animation.play("light")
	if not candle_animation.animation_finished.is_connected(_on_animation_finished):
		candle_animation.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)
	# TODO play a sound effect or smth
	glow_animation.play("settle")
	return true # so the main script knows it has succeeded

func _on_animation_finished() -> void:
	if candle_animation.animation == "light":
		candle_animation.play("glow")

func _play_audio(stream: AudioStream) -> void:
	audio.stream = stream
	audio.play()
