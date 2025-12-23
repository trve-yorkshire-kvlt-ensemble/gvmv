class_name Inventory
extends Node

@export var inventory: InventoryData

func _ready() -> void:
	if inventory and inventory.items == null:
		inventory.items = []

func _find_item_index(item: ItemData) -> int:
	if inventory == null:
		return -1
	for i: int in inventory.items.size():
		var entry: Dictionary = inventory.items[i]
		if entry.has("item") and entry["item"] == item:
			return i
	return -1

func get_quantity(item: ItemData) -> int:
	var idx: int = _find_item_index(item)
	if idx >= 0:
		return int(inventory.items[idx].get("quantity", 0))
	return 0

func add_item(item: ItemData, amount: int = 1) -> void:
	if inventory == null:
		return
	if inventory.items == null:
		inventory.items = []
	var idx: int = _find_item_index(item)
	if idx >= 0:
		inventory.items[idx]["quantity"] = int(inventory.items[idx].get("quantity", 0)) + amount
	else:
		inventory.items.append({"item": item, "quantity": int(amount)})
	EventBus.emit_inventory_updated(self)

func remove_item(item: ItemData, amount: int = 1) -> void:
	if inventory == null or inventory.items == null:
		return
	var idx: int = _find_item_index(item)
	if idx < 0:
		return
	var new_q: int = int(inventory.items[idx].get("quantity", 0)) - amount
	if new_q > 0:
		inventory.items[idx]["quantity"] = new_q
	else:
		inventory.items.remove_at(idx)
	EventBus.emit_inventory_updated(self)

func has_item(item: ItemData) -> bool:
	return _find_item_index(item) >= 0

func has_enough_items(item: ItemData, amount: int) -> bool:
	return get_quantity(item) >= amount
