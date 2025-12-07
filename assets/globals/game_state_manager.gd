# GameStateManager.gd (Autoload Singleton)
extends Node

# Get access to the state constants
const UIState = preload("res://assets/globals/game_enums.gd").UIState

# The current state variable
var current_state: int = UIState.OVERWORLD

# Public function to request a state change
func change_state(new_state: int):
	# Optional: Add error checking or transition logic here
	if current_state == new_state:
		return # No change needed

	current_state = new_state
	print("UI State changed to: ", UIState.keys()[new_state])

	# 1. Emit the signal so all interested nodes can react
	EventBus.emit_ui_state_changed(new_state)

	# 2. Add specific logic/scene loading here if necessary
	if new_state == UIState.COMBAT:
		print("Starting Combat Sequence...")
		# Load Combat Scene, disable Overworld map
	elif new_state == UIState.OVERWORLD:
		print("Returning to Overworld...")
		# Load Overworld Scene, disable Combat UI