extends Resource
class_name PartyMember

var character_data: CharacterData

var level: int = 1
var current_hp: int
var max_hp: int
var xp: int = 0
var attack_power: int
var defense: int
var speed: int

const base_xp_needed: int = 100
const base_xp_multiplier: float = 1.5
const attack_multiplier: float = 1.05
const hp_multiplier: float = 1.1
const defense_multiplier: float = 1.03
const speed_multiplier: float = 1.02

# Call PartyMember.new(character_data) to create a new instance with the given character data
func _init(data: CharacterData = null) -> void:
	character_data = data
	max_hp = data.max_health
	current_hp = max_hp
	level = data.level
	attack_power = data.attack_power
	defense = data.defense
	speed = data.speed

func gain_xp(amount: int) -> void:
	xp += amount
	
	# Check for level up after gaining XP
	while xp >= get_xp_needed_for_next_level():
		level_up()

func get_xp_needed_for_next_level() -> int:
	# Example formula: Base XP * (Level ^ Multiplier)
	return int(base_xp_needed * pow(level, base_xp_multiplier))

func level_up() -> void:
	var xp_needed: int = get_xp_needed_for_next_level()
	
	# 1. Deduct XP and Increment Level on the Resource
	xp -= xp_needed
	level += 1
	
	# 2. Update Stats
	var old_max_hp: int = max_hp
	max_hp = calculate_new_max_hp()
	attack_power = calculate_new_attack()
	defense = calculate_new_defense()
	# speed = calculate_new_speed()	# Uncomment if we want speed to scale with level as well

	# 3. Handle Current HP (Heal/Increase Max HP)
	var hp_gain: int = max_hp - old_max_hp
	current_hp += hp_gain # Heals the character proportional to the Max HP gain
	
	print("%s leveled up! New Level: %s" % [character_data.name, level])

func calculate_new_max_hp() -> int:
	return int(character_data.max_health * pow(hp_multiplier, level - 1))

func calculate_new_attack() -> int:
	return int(character_data.attack_power * pow(attack_multiplier, level - 1))

func calculate_new_defense() -> int:
	return int(character_data.defense * pow(defense_multiplier, level - 1))

func calculate_new_speed() -> int:
	return int(character_data.speed * pow(speed_multiplier, level - 1))