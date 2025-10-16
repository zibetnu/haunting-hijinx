## Avoids strange problems by handling ghost statue synchronization
## outside of the scene tiles themselves.
extends Node


func register_statue(statue: GhostStatue) -> void:
	if not multiplayer.is_server():
		return

	statue.started_watching.connect(
			_on_statue_started_watching.bind(statue.get_path())
	)
	statue.stopped_watching.connect(
			_on_statue_stopped_watching.bind(statue.get_path())
	)


@rpc("authority", "call_remote", "reliable")
func _on_statue_started_watching(target_path: NodePath, statue_path: NodePath) -> void:
	if multiplayer.is_server():
		_on_statue_started_watching.rpc(target_path, statue_path)
		return

	var statue := get_node(statue_path) as GhostStatue
	if statue == null:
		return

	statue.start_watching(target_path)


@rpc("authority", "call_remote", "reliable")
func _on_statue_stopped_watching(statue_path: NodePath) -> void:
	if multiplayer.is_server():
		_on_statue_stopped_watching.rpc(statue_path)
		return

	var statue := get_node(statue_path) as GhostStatue
	if statue == null:
		return

	statue.stop_watching()
