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
	_update_value(int(value))
	
	character.OnTakeDamage.connect(_update_value)
	character.OnHeal.connect(_update_value)

func _update_value(health: int) -> void:
	value = health
	health_text.text = str(health) + " / " + str(int(max_value))
