class_name LootList
extends Resource

@export var minimum_gold: int = 0
@export var maximum_gold: int = 0
@export var minimum_items: int = 1
@export var maximum_items: int = 1
@export var loot_items: Dictionary[ItemData, float] = {}

func generate_items() -> Array[ItemData]:
    var generated_items: Array[ItemData] = []

    var min_count = minimum_items
    var max_count = maximum_items
    var item_count: int
    if max_count <= min_count:
        item_count = min_count
    else:
        item_count = randi() % (max_count - min_count + 1) + min_count

    # Build a mutable list of available items and their weights so we can
    # perform a weighted (cumulative) roll per requested item and avoid
    # selecting duplicates by removing the chosen item from the pool.
    var available_items: Array = loot_items.keys()
    var available_weights: Dictionary = {}
    for it in available_items:
        available_weights[it] = float(loot_items[it])

    # Compute total weight
    var total_weight := 0.0
    for w in available_weights.values():
        total_weight += w

    if total_weight <= 0.0:
        return generated_items

    for i in item_count:
        if available_items.is_empty():
            break

        var roll := randf() * total_weight
        var cumulative := 0.0
        var selected_item = null

        for it in available_items:
            cumulative += available_weights.get(it, 0.0)
            if roll <= cumulative:
                selected_item = it
                break

        if selected_item != null:
            generated_items.append(selected_item)

    return generated_items

func generate_gold() -> int:
    if maximum_gold <= minimum_gold:
        return minimum_gold
    return randi() % (maximum_gold - minimum_gold + 1) + minimum_gold