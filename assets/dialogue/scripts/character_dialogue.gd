class_name CharacterDialogue
extends Node2D

@export var dialogue: Dialogue

func start_conversation() -> void:
    # Start the conversation using the dialogue resource
    EventBus.emit_dialogue_started(dialogue)
    GameStateManager.change_state(GameEnums.UIState.DIALOGUE)