extends Node


@rpc("call_local")
func set_pause(value: bool) -> void:
	get_tree().set_pause(value)
