extends Panel

@onready var combat_manager: Node2D = $"../.."
@onready var enemy_move_text: Label = $EnemyMoveText

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	combat_manager.OnEnemyAction.connect(_enemy_ui)


func _enemy_ui(action: CombatAction, enemy_character: CombatCharacter) -> void:
	enemy_move_text.text = enemy_character.character_name + " has used " + action.display_name
	self.visible = true
	await get_tree().create_timer(0.8).timeout
	self.visible = false
