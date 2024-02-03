extends Node


@export var target_node: Node
@export var bool_name: StringName


func set_bool(value: bool) -> void:
	target_node.set(bool_name, value)


func set_false() -> void:
	target_node.set(bool_name, false)


func set_true() -> void:
	target_node.set(bool_name, true)
