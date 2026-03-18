class_name GameEnums

enum UIState {
	OVERWORLD,      # Default state: Player can move in the world.
	COMBAT,         # Active combat: Player/enemies take turns, movement is disabled.
	INVENTORY,      # Inventory screen open: Player interacts with items, game paused/input locked.
	MENU,           # General main menu, options, etc.
	DIALOGUE        # Dialogue active: Player reads/interacts with dialogue, movement disabled.
}

enum CombatState {
	PLAYER_TURN,
	ENEMY_TURN,
	VICTORY,
	DEFEAT,
}

enum MagicEffect {
	FIRE,
	ICE,
	ELECTRIC,
	HEALING,
	PROTECT,
	POISON,
	CURSE,
	HEX,
	GLITCH,
	SLIME,
	MIST,
	SLEEP,
	SKREAM,
	DREAM
}

enum InteractionType {
	NONE,
	TALK,
	TRADE,
	EXAMINE,
	PICKUP,
	OPEN
}

enum CreatureType {
	FOE,
	FRIEND,
	FOEFRIEND
}
