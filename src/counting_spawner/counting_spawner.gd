class_name CountingSpawner
extends MultiplayerSpawner

# Signal for when all scenes from the server have been spawned. This
# is useful for things that need to wait until those scenes are spawned.
signal all_scenes_spawned

@export var spawned_count_server := 0

var spawned_count_local := 0


func _ready() -> void:
	if not multiplayer.is_server():
		return

	var spawn_node := get_node(spawn_path)
	spawn_node.child_entered_tree.connect(_on_spawn_node_child_entered_tree)
	spawn_node.child_exiting_tree.connect(_on_spawn_node_child_exiting_tree)


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


func _on_spawn_node_child_entered_tree(_node: Node) -> void:
	spawned_count_local += 1
	spawned_count_server = spawned_count_local
	_check_spawn_counts()


func _on_spawn_node_child_exiting_tree(_node: Node) -> void:
	spawned_count_local -= 1
	spawned_count_server = spawned_count_local
	_check_spawn_counts()
