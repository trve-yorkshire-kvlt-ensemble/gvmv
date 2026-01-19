extends ProgressBar

@onready var health_text: Label = $HealthText
var character_data: CharacterData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_parent().ready # wait until parent character is fully initialised
	var char = get_parent()
	character_data = get_parent().character_data
	if character_data == null:
		push_error("HealthBar: character_data is null")
		return
	
	max_value = character_data.max_health
	value = max_value # this initialises health bar as full - we'll probably want to change this later
	print("health bar max: "+str(max_value))
	#max_value = char.max_health
	#print("current health: " + str(char.current_health))
	_update_value(max_value)
	
	char.OnTakeDamage.connect(_update_value)
	char.OnHeal.connect(_update_value)

func _update_value(health: int):
	print("new health bar value: " +str(health))
	value = health
	health_text.text = str(health) + " / " + str(int(max_value))
