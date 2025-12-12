class_name Interactable
extends Node2D

const InteractionType = preload("res://assets/globals/game_enums.gd").InteractionType

@export var interaction_type: InteractionType = InteractionType.EXAMINE
@export var prompt_text: String = "Interact" # What to show the player

# Generic function that the PlayerInteraction calls
# get_parent() will be the actual interactable object (NPC, Item, Container, etc)
func trigger_interaction(player_root_node: Node) -> void:
    var interactable_object = get_parent()
    match interaction_type:
        InteractionType.TALK:
            # The NPC needs the PlayerDialogue component
            # var player_dialogue = player_root_node.get_node("PlayerDialogue")
            # interactable_object.start_conversation(player_dialogue)
            print("Talking to ", interactable_object.name)
        InteractionType.TRADE:
            # The Merchant needs the PlayerCurrency and player's Inventory components
            # var player_currency = player_root_node.get_node("PlayerCurrency")
            # var player_inventory = player_root_node.get_node("Inventory")

            # Pass both components to the trading logic on the NPC
            # interactable_object.open_trade_window(player_currency, player_inventory)

            print("Trading with ", interactable_object.name)
        InteractionType.EXAMINE:
            # The Item or Object shows its description
            # Will this also use the Dialogue system?
            # interactable_object.examine()
            print("Examining ", interactable_object.name)
        InteractionType.PICKUP:
            # The Item needs the player's Inventory component
            # var player_inventory = player_root_node.get_node("Inventory")
            # interactable_object.pickup_item(player_inventory)
            print("Picking up ", interactable_object.name)
        InteractionType.OPEN:
            # The Container needs the player's Inventory component
            var player_inventory: Inventory = player_root_node.get_node("Inventory")
            interactable_object.open_container(player_inventory)