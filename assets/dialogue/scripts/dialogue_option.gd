## A DialogueOption resource representing a single option in a dialogue tree
class_name DialogueOption
extends Resource

@export var text: String = ""  # The text to display for this option
@export var next_dialogue: Resource  # The next dialogue resource to load when this option is selected
@export var required_item: Resource  # An optional item required to select this option
@export var gives_item: Resource  # An optional item given to the player when this option is selected
@export var gold_cost: int = 0  # An optional gold cost to select this option
# @export var required_quest: Resource  # An optional quest required to select this option

func can_select_option(player_data: Resource) -> bool:
    # Check if the player meets the requirements to select this option
    if required_item and not player_data.inventory.has_item(required_item):
        return false
    if gold_cost > player_data.gold:
        return false
    # if required_quest and not player_data.has_completed_quest(required_quest):
    #     return false
    return true