class_name PlayerInteraction
extends Node2D

var interactable_objects: Array[Node2D] = []

func _on_interaction_zone_body_entered(body: Node) -> void:
	# Assuming all interactable objects have a group called "interactable"
	if body.is_in_group("interactable"):
		interactable_objects.append(body)

func _on_interaction_zone_body_exited(body: Node) -> void:
	if body in interactable_objects:
		interactable_objects.erase(body)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if interactable_objects.size() > 0:
			var closest_object: Node2D = get_closest_interactable()
			if closest_object != null:
				# Assuming the object has an "interact" method
				closest_object.trigger_interaction(get_parent())

func get_closest_interactable() -> Node2D:
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
			
	return closest_object
