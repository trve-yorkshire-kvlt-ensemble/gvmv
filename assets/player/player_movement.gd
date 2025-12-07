class_name PlayerMovement
extends CharacterBody2D

# Movement speed (e.g., 200 pixels per second)
@export var speed = 200.0
@export var sprite: Sprite2D

const UIState = preload("res://assets/globals/game_enums.gd").UIState
var can_receive_input: bool = true

func _ready():
	# Listen for state changes
	EventBus.ui_state_changed.connect(_on_ui_state_changed)

func _on_ui_state_changed(new_state: int):	
	# Only allow input if we are in the overworld state
	can_receive_input = (new_state == UIState.OVERWORLD)

func _process(_delta):
	# Check for inventory toggle input
	if Input.is_action_just_pressed("open_inventory"):
		# Request state change through the manager
		if GameStateManager.current_state != UIState.INVENTORY:
			GameStateManager.change_state(UIState.INVENTORY)
		else:
			GameStateManager.change_state(UIState.OVERWORLD)

func _physics_process(_delta):
	if !can_receive_input:
		return # Ignore all movement/action input
	
	# 1. Get player input
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	# Normalize vector to prevent faster diagonal movement
	if input_vector.length() > 1.0:
		input_vector = input_vector.normalized()
	
	# 2. Apply movement velocity
	velocity = input_vector * speed
	
	# 3. Use the built-in physics method to move and handle collisions
	move_and_slide()

	# 4. Update sprite direction based on movement
	if input_vector.x != 0:
		sprite.flip_h = input_vector.x < 0