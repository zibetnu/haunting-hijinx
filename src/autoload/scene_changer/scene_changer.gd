extends Node


@export var lobby: PackedScene
@export var main_menu: PackedScene


func _ready() -> void:
	ConnectionManager.connection_closed.connect(func(): change_scene_to_packed(main_menu))


func change_scene_to_file(path: String) -> void:
	remove_scene()
	if not multiplayer.is_server():
		return

	$SceneContainer.add_child(load(path).instantiate(), true)
	PauseManager.set_pause.rpc(false)


func change_scene_to_packed(packed_scene: PackedScene) -> void:
	remove_scene()
	if not multiplayer.is_server():
		return

	$SceneContainer.add_child(packed_scene.instantiate(), true)
	PauseManager.set_pause.rpc(false)


func remove_scene() -> void:
	for child in $SceneContainer.get_children():
		$SceneContainer.remove_child(child)
		child.queue_free()
