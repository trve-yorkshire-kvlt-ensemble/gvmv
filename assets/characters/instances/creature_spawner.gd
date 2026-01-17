class_name CreatureSpawner
extends Node2D

@export var creature_list: CreatureList
@export var creature_scene: PackedScene

func _ready() -> void:
    if not creature_list:
        push_error("CreatureList not assigned to CreatureSpawner")
        return
    spawn_random_creature()    

func spawn_random_creature() -> void:
    if creature_list and creature_list.creatures.size() > 0:
        var random_index: int = randi() % creature_list.creatures.size()
        var creature_data: CharacterData = creature_list.creatures[random_index]
        var creature_instance: OverworldCharacter = creature_scene.instantiate()
        creature_instance.character_data = creature_data
        add_child(creature_instance)
        creature_instance.global_position = global_position
        if creature_data.sprite:
            creature_instance.get_node("Sprite2D").texture = creature_data.sprite
        else:
            push_error("Creature sprite not assigned in CharacterData")
        if creature_data.name:
            creature_instance.name = creature_data.name
        else:
            creature_instance.name = "Creature_%d" % random_index
    else:
        push_error("CreatureList is empty or not assigned")