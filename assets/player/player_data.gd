class_name PlayerData
extends Resource

@export var inventory: InventoryData
@export var head_item_worn: HeadItem
@export var lantern_item_worn: LanternItem
@export var gold: int = 0

@export var health: int = 100
@export var botulism_level: int = 0

@export var available_party_members: Array[PartyMember] = []
@export var party_members: Array[PartyMember] = []




# todo - current location
# todo - quests
