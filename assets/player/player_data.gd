class_name PlayerData
extends Resource

@export var inventory: InventoryData
@export var head_item_worn: HeadItem
@export var lantern_item_worn: LanternItem
@export var gold: int = 0
@export var botulism_level: int = 0
@export var starting_characters: Array[CharacterData] = []

var available_party_members: Array[PartyMember] = []
var party_members: Array[PartyMember] = []

# todo - current location
# todo - quests

func initialize() -> void:
	# Initialize available party members based on starting characters
	for character_data in starting_characters:
		var new_member: PartyMember = PartyMember.new(character_data)
		available_party_members.append(new_member)
		party_members.append(new_member) # Start with all available members in the party, can be changed later
