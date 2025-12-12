class_name PlayerInteraction
extends Node2D

var interactable_objects = []

func _on_interaction_zone_body_entered(body):
	# Assuming all interactable objects have a group called "interactable"
	if body.is_in_group("interactable"):
		interactable_objects.append(body)

func _on_interaction_zone_body_exited(body):
	if body in interactable_objects:
		interactable_objects.erase(body)

func _input(event):
	if event.is_action_pressed("interact"):
		if interactable_objects.size() > 0:
			var closest_object = get_closest_interactable()
			if closest_object != null:
				# Assuming the object has an "interact" method
				closest_object.trigger_interaction(get_parent())

func get_closest_interactable():
	var closest_object = null
	# Start with a very large distance (or the distance to the first object)
	var min_distance = INF 
	
	# The player's position is the origin for all distance checks
	var player_pos = global_position 

	for obj in interactable_objects:
		# Calculate the distance from the player's center to the object's center
		var distance = player_pos.distance_to(obj.global_position)
		
		# If this object is closer than the current minimum, update
		if distance < min_distance:
			min_distance = distance
			closest_object = obj
			
	return closest_object
