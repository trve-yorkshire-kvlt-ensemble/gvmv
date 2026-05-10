class_name CandleMagick
extends Node2D

@export var available_candles : Array[CandleData] = [] # TODO currently set manually, should load this from player/character inventory
@export var candle_selector_ui : Control
var last_clicked_slot : CandleSlot = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	candle_selector_ui.candle_selected.connect(_on_candle_selected)
	# connect slots - gem told me to do this and I'm not super sure why hvhvhv
	# I think it's connecting the signal?
	for slot in get_tree().get_nodes_in_group("candle_slots"):
		slot.slot_clicked.connect(_on_slot_clicked)
		
	# hide inventory
	candle_selector_ui.hide()

func _on_slot_clicked(slot):
	last_clicked_slot = slot
	#inventory_ui.show_and_populate() # TODO create this func i guess?
	candle_selector_ui.open(available_candles) # TODO load this from inventory
	
# this func called by candle inventory UI
func _on_candle_selected(data: CandleData):
	if last_clicked_slot:
		last_clicked_slot.set_candle(data)
		candle_selector_ui.hide()
		# TODO: trigger something like "ritual completion"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
