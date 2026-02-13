extends Resource
class_name PartyMember

var level: int = 1
var current_hp: int
var max_hp: int
var xp: int = 0

func initialize_from_data(data):
	max_hp = data.base_hp
	current_hp = max_hp

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
