class_name ItemContainer
extends Node

@export var loot_list: LootList

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is PlayerMovement:
		var player_inventory: Inventory = body.get_node_or_null("Inventory")
		if player_inventory != null and loot_list != null:
			var items_to_add: Array[ItemData] = loot_list.generate_items()
			for item in items_to_add:
				player_inventory.add_item(item)
			var gold_amount: int = loot_list.generate_gold()
			# TODO: Add gold to player's inventory or currency system
		#queue_free()  # Remove the container after looting
