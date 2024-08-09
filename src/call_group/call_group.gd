extends Node


@export var group: StringName
@export var method: StringName


func call_group() -> void:
	get_tree().call_group(group, method)
