extends ProgressBar

@onready var health_text: Label = $HealthText
var character_data: CharacterData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_parent().ready # wait until parent character is fully initialised
	var character: CombatCharacter = get_parent()
	character_data = get_parent().character_data
	if character_data == null:
		push_error("HealthBar: character_data is null")
		return
	
	max_value = character_data.max_health
	value = character.current_health
	_update_value(int(value), null, null, null)
	
	character.OnTakeDamage.connect(_update_value)
	character.OnHeal.connect(_update_value)
	
func set_health_color(health_ratio: float) -> void:
	var fill_style := get_theme_stylebox("fill")
	# Important: duplicate so we don't modify a shared theme resource
	fill_style = fill_style.duplicate()
	add_theme_stylebox_override("fill", fill_style)
	if health_ratio > 0.5:
		fill_style.bg_color = Color.GREEN
	elif health_ratio > 0.2:
		fill_style.bg_color = Color.DARK_ORANGE
	else:
		fill_style.bg_color = Color.RED

func _update_value(current_health: int, _amount = null, _type = null, _was_weak = null, _damaged_character = null ) -> void:
	value = current_health
	health_text.text = str(current_health) + " / " + str(int(max_value))
	var health_ratio: float = current_health/max_value
	set_health_color(health_ratio)
