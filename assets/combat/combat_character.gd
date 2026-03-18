# TODO: programmatic update of movesets (currently assigning manually in chcracter_data)
# TODO: need to add something that persists health outside of battle - some kind of state???
# TODO: implement xp and levelling (probs need to discuss!!!)
# TODO: implement accuracy/evasion
# TODO: implement other move types (e.g. mist which affects accuracy? poison?? etc)
# TODO: functionalise floating text bit rather than duplicate in heal and damage

class_name CombatCharacter 
extends Node2D

# character
@export var character_data: CharacterData
@export var is_player: bool 
var current_health: int
var max_health: int
var attack_power: int
var defense: int
var display_name: String
var combat_actions: Array[CombatAction]
var base_magic: GameEnums.MagicEffect
var magic_weakness: GameEnums.MagicEffect
var speed: int
var character_name: String
# var accuracy: float = 1.0   # Chance to hit, can be modified by buffs/debuffs

# audio
@onready var audio: AudioStreamPlayer = $SFX
var take_damage_sfx: AudioStream = preload("res://assets/combat/sfx/ouch.wav")
var heal_sfx: AudioStream = preload("res://assets/combat/sfx/ahh.wav")

# sprite visuals
var target_scale: float = 1.0
@onready var sprite: Sprite2D = $Sprite

# UI
#@onready var number_spawn_pos: Vector2 = $NumberPos.global_position
@onready var type_ui: Panel = $"../../CanvasLayer/TypeUI"
@onready var type_text: Label = $"../../CanvasLayer/TypeUI/TypeText"

# multi party ui stuff (suggested by our ai overlords but I don't 100% get it lol)
# this needs to be referenced in the combat_manager to dynamically determine spacing of sprites
#@export var party_index := 0
#@export var is_enemy := false


# signals
signal OnTakeDamage(current_health: int, amount: int, type: GameEnums.MagicEffect, was_weak: bool, character_name: String)
signal OnHeal(current_health: int, amount: int)
signal OnDied(dead_character: CombatCharacter)


func _ready() -> void:
	if character_data:
		max_health = character_data.max_health
		current_health = character_data.max_health # need to change this to persistent health between battles
		## Set the sprite based on the resource
		sprite.texture = character_data.sprite
		attack_power = character_data.attack_power
		defense = character_data.defense
		display_name = character_data.name
		combat_actions = character_data.combat_actions
		base_magic = character_data.base_magic
		magic_weakness = character_data.magic_weakness
		speed = character_data.speed
		character_name = character_data.name

func _process(delta: float) -> void:
	scale.x = lerp(scale.x, target_scale, delta*10)
	scale.y = lerp(scale.y, target_scale, delta*10)

func is_alive() -> bool:
	return current_health > 0

func begin_turn() -> void:
	target_scale = 0.8

func end_turn() -> void:
	target_scale = 0.6
	
func take_damage(amount: int, type: GameEnums.MagicEffect) -> void:
	# roll for damage reduction (based on defense stat)
	var damage_reduction: int = randi_range(0, defense)
	amount -= damage_reduction
	# additional damage if weak to attack type
	# NB. this sort of a placeholder... this isn't good logic ^_^
	var was_weak := false
	if type == magic_weakness:
		was_weak = true
		amount += damage_reduction
	current_health -= amount
	current_health = max(current_health, 0)
	OnTakeDamage.emit(current_health, amount, type, was_weak, character_name) # this triggers visuals etc
	_play_audio(take_damage_sfx)
	
	if not is_alive():
		OnDied.emit(self)


func heal(amount: int) -> void:
	current_health += amount
	current_health = clamp(current_health, 0, max_health) # keep health within min/max bounds
	OnHeal.emit(current_health, amount) # triggers visual
	_play_audio(heal_sfx)


func cast_combat_action(action: CombatAction, targets: Array[CombatCharacter]) -> void:
	if action == null:
		return
	for target in targets:
		if action.base_melee_damage > 0:
			# roll for additional damage based on attack power
			var additional_damage: int = randi_range(0, attack_power)
			var damage: int = action.base_melee_damage + additional_damage
			# double roll if damage type aligns with base magic
			# could maybe roll again here instead?
			# or could get rid of this if we are only letting characters cast their base magic
			if action.damage_type == base_magic:
				damage += additional_damage
			print("dealing " + str(damage) + " damage!")
			target.take_damage(damage, action.damage_type)

		if action.heal_amount > 0:
			target.heal(action.heal_amount)


func _play_audio(stream: AudioStream) -> void:
	audio.stream = stream
	audio.play()

########## lolo's xp and health stuff has mostly moved to PartyMember ##########

# thinking about state of e.g. xp and health:
# something like this?
# need to look at lyra's global data thingie
#func load_from_state(state):
	#current_health = state.current_health
#
#func save_to_state(state):
	#state.current_health = current_health
