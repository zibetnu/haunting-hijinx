extends Node


var _info := {}


func get_info() -> Dictionary:
	return _info


@rpc("call_local")
func set_pause(value: bool, info := {}) -> void:
	if value == get_tree().is_paused():
		return

	_info = info
	if not allow_set_pause():
		return

	get_tree().call_group("pause_sync", "_on_set_pause", value)
	get_tree().set_pause(value)


func allow_set_pause() -> bool:
	for node in get_tree().get_nodes_in_group("pause_sync"):
		if not node.has_method("allow_set_pause"):
			continue

		if not node.allow_set_pause():
			return false

	return true
