# TODO: programmatic update of movesets (currently assigning manually in chcracter_data)
# TODO: need to add something that persists health outside of battle - some kind of state???
# TODO: implement xp and levelling (probs need to discuss!!!)
# TODO: implement accuracy/evasion
# TODO: implement other move types (e.g. mist which affects accuracy? poison?? etc)
# TODO: functionalise floating text bit rather than duplicate in heal and damage

class_name CombatCharacter 
extends Node2D

# constants
const MagicEffect = preload("res://assets/globals/game_enums.gd").MagicEffect
const FLOATING_TEXT_SCENE = preload("res://assets/combat/floating_text.tscn")
# const base_xp_needed: int = 100
# const base_xp_multiplier: float = 1.5

# character
@export var character_data: CharacterData
@export var is_player: bool 
var current_health: int
var max_health: int
var attack_power: int
var defense: int
var display_name: String
var combat_actions: Array[CombatAction]
var base_magic: MagicEffect
var magic_weakness: MagicEffect
# var current_xp: int = 0
# var accuracy: float = 1.0   # Chance to hit, can be modified by buffs/debuffs

# audio
@onready var audio: AudioStreamPlayer = $SFX
var take_damage_sfx: AudioStream = preload("res://assets/combat/sfx/ouch.wav")
var heal_sfx: AudioStream = preload("res://assets/combat/sfx/ahh.wav")

# sprite visuals
var target_scale: float = 1.0
@onready var sprite: Sprite2D = $Sprite
@export var display_texture: Texture2D

# UI
@onready var number_spawn_pos: Vector2 = $NumberPos.global_position
@onready var type_ui: Panel = $"../CanvasLayer/TypeUI"
@onready var type_text: Label = $"../CanvasLayer/TypeUI/TypeText"

# signals
signal OnTakeDamage(health : int)
signal OnHeal (health : int)

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

func _process(delta: float) -> void:
	scale.x = lerp(scale.x, target_scale, delta*10)
	scale.y = lerp(scale.y, target_scale, delta*10)

func begin_turn() -> void:
	target_scale = 1.1

func end_turn() -> void:
	target_scale = 0.9
	
func take_damage(amount: int, type: MagicEffect) -> void:
	# roll for damage reduction (based on defense stat)
	var damage_reduction: int = randi_range(0, defense)
	amount -= damage_reduction
	# additional damage if weak to attack type
	# NB. this sort of a placeholder... this isn't good logic ^_^
	if type == magic_weakness:
		type_ui.visible = true
		type_text.text = character_data.name + " is weak against " + MagicEffect.keys()[type]
		amount += damage_reduction
	current_health -= amount
	OnTakeDamage.emit(current_health) # this triggers visuals
	_play_audio(take_damage_sfx)
	# trigger floating damage label
	var text_node: Label = FLOATING_TEXT_SCENE.instantiate()
	get_tree().root.add_child(text_node)
	var text_colour: Color = Color.RED
	text_node.display(amount, text_colour, number_spawn_pos)
	
func heal(amount: int) -> void:
	current_health += amount
	current_health = clamp(current_health, 0, max_health) # keep health within min/max bounds
	OnHeal.emit(current_health) # triggers visual
	_play_audio(heal_sfx)
	# trigger floating heal label
	var text_node: Label = FLOATING_TEXT_SCENE.instantiate()
	get_tree().root.add_child(text_node)
	var text_colour: Color = Color.GREEN
	text_node.display(amount, text_colour, number_spawn_pos)
	
func cast_combat_action(action: CombatAction, opponent: CombatCharacter) -> void:
	if action == null:
		return

	if action.base_melee_damage > 0:
		# roll for additional damage based on attack power
		var additional_damage: int = randi_range(0, attack_power)
		var damage: int = action.base_melee_damage + additional_damage
		# double roll if damage type aligns with base magic
		# could maybe roll again here instead?
		# or could get rid of this if we are only letting characters cast their base magic
		if action.damage_type == base_magic:
			damage += additional_damage
		opponent.take_damage(damage, action.damage_type)

	if action.heal_amount >0:
		heal(action.heal_amount)
		
func _play_audio(stream: AudioStream) -> void:
	audio.stream = stream
	audio.play()

########## lolo's xp stuff that we probs still want to use ##########
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





########## lolo's old funcs that I think are superceded ##########
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
