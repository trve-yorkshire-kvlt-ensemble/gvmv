extends Label

# our merciful ai overlord gemini wrote this script

func display(value: int, color: Color, start_pos: Vector2):
	text = str(value)
	modulate = color
	global_position = start_pos
	
	var tween = create_tween().set_parallel(true)
	
	# 1. The "Burst" Effect: Move it up and slightly sideways
	var move_to = start_pos + Vector2(randf_range(-20, 20), -50)
	tween.tween_property(self, "global_position", move_to, 0.75).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# 2. The Scale Effect: Start small, pop big, then settle
	scale = Vector2.ZERO
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2).set_trans(Tween.TRANS_ELASTIC)
	
	# 3. The Fade Out: Start fading after a short delay
	tween.chain().tween_property(self, "modulate:a", 0.0, 0.5)
	
	# Clean up: Remove the node once the animation is done
	tween.finished.connect(queue_free)
