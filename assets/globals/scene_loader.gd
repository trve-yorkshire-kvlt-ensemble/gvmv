# Autoload scene loader for managing scene transitions and loading screens
extends Node

signal progress_updated(percent: float)
signal loading_complete

var loading_screen: PackedScene #= preload(Constants.SCENE_PATHS["loading_screen"])
var loaded_resource: PackedScene
var scene_path: String
var progress: Array = []
var use_sub_threads: bool = true

func _ready() -> void:
    set_process(false)

func load_scene(path: String) -> void:
    scene_path = path
    if loading_screen:
        var new_load_screen: CanvasLayer = loading_screen.instantiate()
        add_child(new_load_screen)
        progress_updated.connect(new_load_screen.update_progress)
        loading_complete.connect(new_load_screen.queue_free)

        await new_load_screen.loading_screen_ready
    
    start_loading()

func start_loading() -> void:
    var state: int = ResourceLoader.load_threaded_request(scene_path, "", use_sub_threads)
    if state == OK:
        set_process(true)
    else:
        push_error("Failed to start loading scene: " + scene_path)

func _process(_delta: float) -> void:
    var status: int = ResourceLoader.load_threaded_get_status(scene_path, progress)
    progress_updated.emit(progress[0])
    match status:
        ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
            push_error("Failed to load scene: " + scene_path)
            set_process(false)
        ResourceLoader.THREAD_LOAD_LOADED:
            loaded_resource = ResourceLoader.load_threaded_get(scene_path)
            get_tree().change_scene_to_packed(loaded_resource)
            loading_complete.emit()
            set_process(false)
