class_name CombatCharacter 
extends Node2D

@export var character_data: CharacterData

var current_health: int
var current_xp: int = 0
var accuracy: float = 1.0   # Chance to hit, can be modified by buffs/debuffs

const base_xp_needed: int = 100
const base_xp_multiplier: float = 1.5

func _ready():
    if character_data:
        current_health = character_data.max_health

        # Set the sprite based on the resource
        $Sprite2D.texture = character_data.sprite_texture
    else:
        push_error("Character data not assigned for %s" % self.name)

func is_alive() -> bool:
    return current_health > 0

func take_damage(amount: int) -> int:
    var damage_taken = character_data.calculate_defense(amount)
    current_health -= damage_taken
    current_health = max(0, current_health)
    return damage_taken

func attack_target(target: CombatCharacter) -> int:
    var damage_dealt = character_data.calculate_attack(target.character_data.defense)
    target.take_damage(damage_dealt)
    return damage_dealt

func heal(amount: int) -> void:
    current_health += amount
    current_health = min(current_health, character_data.max_health)

func gain_xp(amount: int) -> void:
    current_xp += amount
    
    # Check for level up after gaining XP
    while current_xp >= character_data.get_xp_needed_for_next_level():
        level_up()

func get_xp_needed_for_next_level() -> int:
    # Example formula: Base XP * (Level ^ Multiplier)
    return int(base_xp_needed * pow(character_data.level, base_xp_multiplier))

func level_up() -> void:
    var xp_needed = character_data.get_xp_needed_for_next_level()
    
    # 1. Deduct XP and Increment Level on the Resource
    current_xp -= xp_needed
    character_data.level += 1
    
    # 2. Update Stats (Mutate the Resource data)
    #var old_max_hp = character_data.max_hp
    #character_data.max_hp = character_data.calculate_new_max_hp()
    #character_data.attack_power = character_data.calculate_new_attack()
    
    # 3. Handle Current HP (Heal/Increase Max HP)
    #var hp_gain = character_data.max_hp - old_max_hp
    #current_hp += hp_gain # Heals the character proportional to the Max HP gain
    
    print("%s leveled up! New Level: %s" % [character_data.name, character_data.level])