extends Sprite2D

var bob_amount: float = 0.15
var bob_speed: float = 12.0

@onready var base_offset: Vector2 = offset
var shake_intensity: float = 0.0
var shake_damping: float = 10.0

const FLOATING_TEXT_SCENE = preload("res://assets/combat/floating_text.tscn")
const MagicEffect = preload("res://assets/globals/game_enums.gd").MagicEffect
@onready var number_spawn_pos: Vector2 = $"../NumberPos".global_position

func _ready() -> void:
	var character: CombatCharacter = get_parent()
	character.OnTakeDamage.connect(_damage_visual)
	character.OnHeal.connect(_heal_visual)
	
func _process(delta: float) -> void:
	var t: float = Time.get_unix_time_from_system()
	var y_scale: float = 5 + (sin(t * bob_speed) * bob_amount)
	scale.y = y_scale
	
	if shake_intensity >0:
		shake_intensity = lerpf(shake_intensity, 0, shake_damping * delta)
		offset = base_offset + _random_offset()

func _damage_visual(_current_health: int, amount: int, _type: MagicEffect, _was_weak: bool) -> void:
	modulate = Color.DARK_RED
	shake_intensity = 10.0
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
		# going to change the below to be triggered by the signal instead
	# trigger floating damage label
	var text_node: Label = FLOATING_TEXT_SCENE.instantiate()
	get_tree().root.add_child(text_node)
	var text_colour: Color = Color.RED
	text_node.display(amount, text_colour, number_spawn_pos)
	
func _heal_visual(_health: int) -> void:
	modulate = Color.GREEN
	await get_tree().create_timer(0.2).timeout
	modulate = Color.WHITE

func _random_offset() -> Vector2:
	var x: float = randf_range(-shake_intensity, shake_intensity)
	var y: float = randf_range(-shake_intensity, shake_intensity)
	return Vector2(x,y)
