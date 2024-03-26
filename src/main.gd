extends Node


@export var start_scene: PackedScene


func _ready() -> void:
	SceneChanger.change_scene_to_packed(start_scene)
	queue_free()
