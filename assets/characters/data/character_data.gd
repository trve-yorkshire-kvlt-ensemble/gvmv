class_name CharacterData
extends Resource

const MagicEffect = preload("res://assets/globals/game_enums.gd").MagicEffect

@export var name: String = "Unnamed Character"
@export var sprite: Texture2D

@export var max_health: int = 100
@export var level: int = 1
@export var attack_power: int = 10
@export var defense: int = 5
@export var speed: int = 10
@export var base_magic: MagicEffect = MagicEffect.FIRE

func calculate_attack(target_defense: int) -> int:
    var damage = attack_power - target_defense
    return max(1, damage)

func calculate_defense(incoming_attack: int) -> int:
    var reduced_damage = incoming_attack - defense
    return max(0, reduced_damage)