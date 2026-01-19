# TODO: programmatic update of movesets (currently assigning manually in UI)
# but these could/should load from character data?
# TODO: currently just using base melee damage amount - need to add in functionality for level multiplier
# TODO: need to add something that persists health outside of battle - some kind of state???

class_name CombatCharacter 
extends Node2D

@export var character_data: CharacterData

@export var is_player: bool 
var current_health: int
var max_health: int
var attack_power: int
var defense: int
var display_name: String
@export var combat_actions: Array[CombatAction]
#@export var display_name: String
var target_scale: float = 1.0
@onready var audio: AudioStreamPlayer = $SFX
var take_damage_sfx: AudioStream = preload("res://assets/combat/sfx/ouch.wav")
var heal_sfx: AudioStream = preload("res://assets/combat/sfx/ahh.wav")
@onready var sprite: Sprite2D = $Sprite
@export var display_texture: Texture2D


# var current_xp: int = 0
# var accuracy: float = 1.0   # Chance to hit, can be modified by buffs/debuffs

# const base_xp_needed: int = 100
# const base_xp_multiplier: float = 1.5

signal OnTakeDamage(health : int)
signal OnHeal (health : int)

func _ready() -> void:
	#sprite.texture = display_texture
	if character_data:
		max_health = character_data.max_health
		current_health = character_data.max_health # need to change this to persistent health between battles
		## Set the sprite based on the resource
		sprite.texture = character_data.sprite
		# set the characters level based on resource
		# although probably level should be a state thing rather than on the resource
		# (same as current health)
		attack_power = character_data.attack_power
		defense = character_data.defense
		display_name = character_data.name
	#else:
		#push_error("Character data not assigned for %s" % self.name)
	

func _process(delta):
	scale.x = lerp(scale.x, target_scale, delta*10)
	scale.y = lerp(scale.y, target_scale, delta*10)

func begin_turn():
	target_scale = 1.1

func end_turn():
	target_scale = 0.9
	
func take_damage(amount: int):
	var damage_reduction: int = randi_range(0, defense)
	amount -= damage_reduction
	current_health -= amount
	OnTakeDamage.emit(current_health)
	_play_audio(take_damage_sfx)
	
func heal(amount: int):
	current_health += amount
	current_health = clamp(current_health, 0, max_health)
	OnHeal.emit(current_health)
	_play_audio(heal_sfx)
	
func cast_combat_action(action: CombatAction, opponent: CombatCharacter):
	if action == null:
		return
	if action.base_melee_damage > 0:
		var additional_damage = randi_range(0, attack_power)
		opponent.take_damage(action.base_melee_damage + additional_damage)
	if action.heal_amount >0:
		heal(action.heal_amount)
		
func _play_audio(stream: AudioStream):
	audio.stream = stream
	audio.play()

#func is_alive() -> bool:
	#return current_health > 0

#func take_damage(amount: int) -> int:
	#var damage_taken: int = character_data.calculate_defense(amount)
	#current_health -= damage_taken
	#current_health = max(0, current_health)
	#return damage_taken

#func attack_target(target: CombatCharacter) -> int:
	#var damage_dealt: int = character_data.calculate_attack(target.character_data.defense)
	#target.take_damage(damage_dealt)
	#return damage_dealt

#func heal(amount: int) -> void:
	#current_health += amount
	#current_health = min(current_health, character_data.max_health)

#func gain_xp(amount: int) -> void:
	#current_xp += amount
	#
	## Check for level up after gaining XP
	#while current_xp >= character_data.get_xp_needed_for_next_level():
		#level_up()

#func get_xp_needed_for_next_level() -> int:
	## Example formula: Base XP * (Level ^ Multiplier)
	#return int(base_xp_needed * pow(character_data.level, base_xp_multiplier))

#func level_up() -> void:
	#var xp_needed: int = character_data.get_xp_needed_for_next_level()
	#
	## 1. Deduct XP and Increment Level on the Resource
	#current_xp -= xp_needed
	#character_data.level += 1
	
	# 2. Update Stats (Mutate the Resource data)
	#var old_max_hp = character_data.max_hp
	#character_data.max_hp = character_data.calculate_new_max_hp()
	#character_data.attack_power = character_data.calculate_new_attack()
	
	# 3. Handle Current HP (Heal/Increase Max HP)
	#var hp_gain = character_data.max_hp - old_max_hp
	#current_hp += hp_gain # Heals the character proportional to the Max HP gain
	
	#print("%s leveled up! New Level: %s" % [character_data.name, character_data.level])
