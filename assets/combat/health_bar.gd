extends ProgressBar

@onready var health_text: Label = $HealthText

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var char = get_parent()
	#print(char)
	max_value = char.max_health
	print(char.max_health)
	_update_value(char.current_health)
	
	char.OnTakeDamage.connect(_update_value)
	char.OnHeal.connect(_update_value)

func _update_value(health: int):
	value = health
	health_text.text = str(health) + " / " + str(int(max_value))
