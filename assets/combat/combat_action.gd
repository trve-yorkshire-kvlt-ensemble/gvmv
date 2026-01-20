# TODO implement follow up message - e,g, Magikarp used splash, nothing happened
# current_character + " used " + move + ". " + follow_up_message

class_name CombatAction
extends Resource

const MagicEffect = preload("res://assets/globals/game_enums.gd").MagicEffect

@export var display_name: String
@export var description: String
@export var base_melee_damage: int = 0
@export var heal_amount: int = 0
@export var base_weight: int = 100 # this is for the AI
@export var damage_type: MagicEffect 
@export var follow_up_message: String 
