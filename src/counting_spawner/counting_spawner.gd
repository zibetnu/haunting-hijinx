class_name CountingSpawner
extends MultiplayerSpawner


# Signal for when a client has spawned all of the scenes from the server. This
# is useful for things that need to wait until those scenes are spawned.
signal all_scenes_spawned

@export var spawned_count_server := 0

var spawned_count_local := 0


func _process(_delta: float) -> void:
	if not multiplayer.is_server():
		set_process(false)
		return

	spawned_count_server = get_node(spawn_path).get_child_count()


# TODO: add more robust checks that ensure the same scenes
# are spawned instead of just the same number of scenes.
func _check_spawn_counts() -> void:
	if spawned_count_local >= spawned_count_server:
		all_scenes_spawned.emit()


func _on_despawned(_node: Node) -> void:
	spawned_count_local -= 1


func _on_multiplayer_synchronizer_delta_synchronized() -> void:
	_check_spawn_counts()


func _on_multiplayer_synchronizer_synchronized() -> void:
	_check_spawn_counts()


func _on_spawned(_node: Node) -> void:
	spawned_count_local += 1
