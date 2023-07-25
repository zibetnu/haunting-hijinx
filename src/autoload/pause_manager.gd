extends Node


@rpc("call_local")
func set_pause(enable: bool) -> void:
	get_tree().set_pause(enable)
