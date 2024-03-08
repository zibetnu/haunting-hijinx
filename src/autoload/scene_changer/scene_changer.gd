extends Node


@export var lobby: PackedScene
@export var main_menu: PackedScene


func _ready() -> void:
	multiplayer.server_disconnected.connect(func(): change_scene_to_packed(main_menu))


func change_scene_to_file(path: String) -> void:
	remove_scene()
	$SceneContainer.add_child(load(path).instantiate(), true)


func change_scene_to_packed(packed_scene: PackedScene) -> void:
	remove_scene()
	$SceneContainer.add_child(packed_scene.instantiate(), true)


func remove_scene() -> void:
	for child in $SceneContainer.get_children():
		$SceneContainer.remove_child(child)
		child.queue_free()
