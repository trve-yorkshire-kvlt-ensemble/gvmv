extends Control

signal candle_selected(data:CandleData)

@onready var grid = $CandleContainer/VBoxContainer/ScrollContainer/GridContainer
@export var button_scene : PackedScene

func open(player_inventory: Array):
	# clear old buttons
	for child in grid.get_children():
		# again not 100% sure on what's going on here cause gem is helping
		grid.remove_child(child) # Get it out of the grid layout NOW
		child.queue_free()       # Delete it from memory LATER
		#child.queue_free()
	
	# create new buttons
	# OKAY so ideall here we want to scan the player's inventory and add candles
	# for now I'll just pass an array of candles (and maybe some other stuff to test it)
	for item in player_inventory:
		if item is CandleData:
			print("creating button for: ", item.name)
			var btn = button_scene.instantiate()
			grid.add_child(btn)
			btn.texture_normal = item.texture
			btn.pressed.connect(func(): _on_item_clicked(item))
	show()
	
func _on_item_clicked(item: CandleData):
	candle_selected.emit(item)
	hide()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
