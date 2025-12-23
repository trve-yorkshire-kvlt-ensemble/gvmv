extends Node

# signal player_health_changed(new_health: int)
signal inventory_updated(inventory: Inventory)

func emit_inventory_updated(inventory: Inventory) -> void:
	inventory_updated.emit(inventory)

# We use a simple integer, expecting the enum value from GameEnums.UIState
signal ui_state_changed(new_state: int)

# Wrapper to emit the state change
func emit_ui_state_changed(state: int) -> void:
	ui_state_changed.emit(state)