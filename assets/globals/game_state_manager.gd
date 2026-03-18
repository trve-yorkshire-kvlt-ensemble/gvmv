# GameStateManager.gd (Autoload Singleton)
extends Node

# The current state variable
var current_state: int = GameEnums.UIState.OVERWORLD

# Public function to request a state change
func change_state(new_state: int) -> void:
	# Optional: Add error checking or transition logic here
	if current_state == new_state:
		return # No change needed

	current_state = new_state
	print("UI State changed to: ", GameEnums.UIState.keys()[new_state])

	# 1. Emit the signal so all interested nodes can react
	EventBus.emit_ui_state_changed(new_state)

	# 2. Add specific logic/scene loading here if necessary
	if new_state == GameEnums.UIState.COMBAT:
		print("Starting Combat Sequence...")
		# Load Combat Scene, disable Overworld map
	elif new_state == GameEnums.UIState.OVERWORLD:
		print("Returning to Overworld...")
		# Load Overworld Scene, disable Combat UI
