class_name CharacterDialogue
extends Node2D

const UIState = preload("res://assets/globals/game_enums.gd").UIState

@export var dialogue: Dialogue

func start_conversation() -> void:
    # Start the conversation using the dialogue resource
    EventBus.emit_dialogue_started(dialogue)
    GameStateManager.change_state(UIState.DIALOGUE)