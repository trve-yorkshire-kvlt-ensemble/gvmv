class_name InventorySlot
extends Control

@export var icon: TextureRect
@export var quantity_label: Label

var item: ItemData = null

func set_item(new_item: ItemData, quantity: int) -> void:
    item = new_item
    if item != null:
        icon.texture = item.icon
        icon.visible = true
        quantity_label.text = str(quantity)
    else:
        clear_slot()

func clear_slot() -> void:
    item = null
    icon.texture = null
    icon.visible = false
    quantity_label.text = ""