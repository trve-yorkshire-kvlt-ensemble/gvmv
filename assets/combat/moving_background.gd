extends TextureRect

@export var speed: float = 100
@export var extents: float = 1024
@onready var start_pos: Vector2 = position
@export var colour_lerp: Gradient


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += speed * delta
	if position.x - start_pos.x >= extents:
		position = start_pos
	var time = sin(Time.get_unix_time_from_system())
	time = (time + 1) / 2
	modulate = colour_lerp.sample(time)
