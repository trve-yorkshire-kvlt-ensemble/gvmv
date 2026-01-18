# TODO implement damage types - should we think about pokemon style type matchups?
# TODO implement damage mutiplier based on level
# TODO implement follow up message - e,g, Magikarp used splash, nothing happened
# current_character + " used " + move + ". " + follow_up_message

class_name CombatAction
extends Resource

@export var display_name: String
@export var description: String
@export var base_melee_damage: int = 0
@export var heal_amount: int = 0
@export var base_weight: int = 100 # this is for the AI
@export var damage_type: String # to be implemented
@export var follow_up_message: String # to be implemented

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
