class_name PlayerInteraction
extends Node2D

signal closest_interactable_changed(interactable: Node2D)

var interactable_objects: Array[Node2D] = []
var current_closest: Node2D = null

func _on_interaction_zone_body_entered(body: Node) -> void:
	# Assuming all interactable objects have a group called "interactable"
	if body.is_in_group("interactable"):
		interactable_objects.append(body)
		_update_closest_interactable()

func _on_interaction_zone_body_exited(body: Node) -> void:
	if body in interactable_objects:
		interactable_objects.erase(body)
		_update_closest_interactable()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if current_closest != null:
			# Assuming the object has an "interact" method
			current_closest.trigger_interaction(get_parent())

func _update_closest_interactable() -> void:
	var closest_object: Node2D = null
	# Start with a very large distance (or the distance to the first object)
	var min_distance: float = INF 
	
	# The player's position is the origin for all distance checks
	var player_pos: Vector2 = global_position 

	for obj: Node2D in interactable_objects:
		# Calculate the distance from the player's center to the object's center
		var distance: float = player_pos.distance_to(obj.global_position)
		
		# If this object is closer than the current minimum, update
		if distance < min_distance:
			min_distance = distance
			closest_object = obj
	
	# Only emit signal if it actually changed
	if closest_object != current_closest:
		current_closest = closest_object
		closest_interactable_changed.emit(current_closest)
