## A DialogueOption resource representing a single option in a dialogue tree
class_name DialogueOption
extends Resource

@export var text: String = ""  # The text to display for this option
@export var next_dialogue: Resource  # The next dialogue resource to load when this option is selected
@export var required_item: Resource  # An optional item required to select this option
@export var gives_item: Resource  # An optional item given to the player when this option is selected
@export var gold_cost: int = 0  # An optional gold cost to select this option