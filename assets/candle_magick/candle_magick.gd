class_name CandleMagick
extends Node2D

@export var available_candles : Array[CandleData] = [] # TODO currently set manually, should load this from player/character inventory
@export var candle_selector_ui : Control
var last_clicked_slot : CandleSlot = null


@onready var glow_line: Line2D = $GlowLine
@onready var line_container: Node2D = $GlowLine/LineContainer  # this is just to keep the lines in the right order in the scene
var candle_positions: Array[Dictionary] = [] # position and colour of candle { "pos": Vector2, "data": CandleData }


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	candle_selector_ui.candle_selected.connect(_on_candle_selected)
	# connect slots - gem told me to do this and I'm not super sure why hvhvhv
	# I think it's connecting the signal?
	for slot in get_tree().get_nodes_in_group("candle_slots"):
		slot.slot_clicked.connect(_on_slot_clicked)
		
	# hide inventory
	candle_selector_ui.hide()
	
	# clear any lines
	glow_line.clear_points()

func _on_slot_clicked(slot) -> void:
	last_clicked_slot = slot
	#inventory_ui.show_and_populate() # TODO create this func i guess?
	candle_selector_ui.open(available_candles) # TODO load this from inventory
	
# this func called by candle inventory UI
func _on_candle_selected(data: CandleData) -> void:
	if last_clicked_slot:
		var is_new: bool = last_clicked_slot.set_candle(data)
		candle_selector_ui.hide()
		
		# only draw if not already there
		if is_new:
			# get position
			#var new_pos: Vector2 = last_clicked_slot.global_position
			# get centre of sprite
			var new_pos: Vector2 = last_clicked_slot.global_position + (last_clicked_slot.size * last_clicked_slot.scale) / 2.0
			# draw lines to _all_ existing candles
			_connect_to_all_existing(new_pos, data)
			# add slot to our tracked positions
			candle_positions.append({
				"pos": new_pos,
				"data": data
				})
			
		# TODO: trigger something like "ritual completion"

func _connect_to_all_existing(new_pos: Vector2, new_data: CandleData) -> void:
	for candle in candle_positions:
		var start_pos: Vector2 = candle["pos"]
		var start_data: CandleData = candle["data"]
		# spawn a new line for each segment
		var line := Line2D.new()
		line.width = glow_line.width
		#line.default_color = glow_line.default_color
		line.texture_mode = glow_line.texture_mode
		line.joint_mode = glow_line.joint_mode
		line.begin_cap_mode = glow_line.begin_cap_mode
		line.end_cap_mode = glow_line.end_cap_mode
		line.material = glow_line.material
		line.texture = glow_line.texture
		
		var line_gradient := Gradient.new()
		line_gradient.set_color(0, start_data.get_colour())
		line_gradient.set_color(1, new_data.get_colour())
		# assign gradient
		line.gradient = line_gradient
		line.add_point(glow_line.to_local(start_pos))
		line.add_point(glow_line.to_local(new_pos))
		
		line_container.add_child(line)
		



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
