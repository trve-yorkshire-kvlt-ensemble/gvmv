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
@export var combat_actions: Array[CombatAction]
@export var magic_weakness: MagicEffect = MagicEffect.ICE
@export var initially_hostile: bool = false



## I've handled for this in other combat bits but leaving here in case we need to reference it
#func calculate_attack(target_defense: int) -> int:
	#var damage: int = attack_power - target_defense
	#return max(1, damage)
#
#func calculate_defense(incoming_attack: int) -> int:
	#var reduced_damage: int = incoming_attack - defense
	#return max(0, reduced_damage)
