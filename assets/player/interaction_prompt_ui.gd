class_name InteractionPromptUI
extends Label

@onready var player_interaction: PlayerInteraction = get_parent()

# Offset above the target object
var offset_above: float = 10.0

func _ready() -> void:
	# Connect to the signal from PlayerInteraction
	player_interaction.closest_interactable_changed.connect(_on_closest_interactable_changed)
	# Start hidden
	visible = false

func _process(_delta: float) -> void:
	# Keep label positioned above the closest object if one exists
	if player_interaction.current_closest != null:
		var target_pos: Vector2 = player_interaction.current_closest.global_position
		# Position above the object
		global_position = target_pos - Vector2(size.x / 2, size.y + offset_above)

func _on_closest_interactable_changed(interactable: Node2D) -> void:
	if interactable != null:
		visible = true
		# Cast the node directly to Interactable
		var interactable_component: Interactable = interactable as Interactable
		if interactable_component != null:
			text = interactable_component.prompt_text
		else:
			text = "Interact"
	else:
		visible = false
