## An Interactable component that goes on a child Node2D of an interactable object
## The parent Node2D is the actual interactable object (NPC, Item, Container, etc)
class_name Interactable
extends Node2D

@export var interaction_type: GameEnums.InteractionType = GameEnums.InteractionType.EXAMINE
@export var prompt_text: String = "Interact" # What to show the player

# Generic function that the PlayerInteraction calls
func trigger_interaction(player_root_node: Node) -> void:
	# get_parent() will be the actual interactable object (NPC, Item, Container, etc)
	var interactable_object: Node2D = get_parent()
	
	match interaction_type:
		GameEnums.InteractionType.TALK:
			var character: OverworldCharacter = interactable_object as OverworldCharacter
			character.start_dialogue()
			print("Talking to ", character.character_data.name)
		GameEnums.InteractionType.TRADE:
			# The Merchant needs the PlayerCurrency and player's Inventory components
			# var player_currency = player_root_node.get_node("PlayerCurrency")
			# var player_inventory = player_root_node.get_node("Inventory")

			# Pass both components to the trading logic on the NPC
			# interactable_object.open_trade_window(player_currency, player_inventory)

			print("Trading with ", interactable_object.name)
		GameEnums.InteractionType.EXAMINE:
			# The Item or Object shows its description
			# Will this also use the Dialogue system?
			# interactable_object.examine()
			print("Examining ", interactable_object.name)
		GameEnums.InteractionType.PICKUP:
			# The Item needs the player's Inventory component
			# var player_inventory = player_root_node.get_node("Inventory")
			# interactable_object.pickup_item(player_inventory)
			print("Picking up ", interactable_object.name)
		GameEnums.InteractionType.OPEN:
			# The Container needs the player's Inventory component
			var player_inventory: Inventory = player_root_node.get_node("Inventory")
			interactable_object.open_container(player_inventory)
