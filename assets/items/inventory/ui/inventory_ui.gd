class_name InventoryUI
extends CanvasLayer

@export var slots: Array[InventorySlot] = []

const UIState = preload("res://assets/globals/game_enums.gd").UIState

func _ready() -> void:
	EventBus.inventory_updated.connect(update_ui)
	EventBus.ui_state_changed.connect(_on_ui_state_changed)

func _on_ui_state_changed(new_state: int) -> void:
	# Check the signal payload and manage local visibility
	if new_state == UIState.INVENTORY:
		# When INVENTORY state is active, show self
		visible = true
	else:
		# In any other state (OVERWORLD, COMBAT, etc.), hide self
		visible = false

func update_ui(inventory: Inventory) -> void:
	for i: int in range(slots.size()):
		var slot: InventorySlot = slots[i]
		if inventory.inventory.items.size() > i:
			var entry: Dictionary = inventory.inventory.items[i]
			slot.set_item(entry.get("item", null), int(entry.get("quantity", 0)))
		else:
			slot.clear_slot()
