extends Node

signal attempt_failed
signal attempt_succeeded

@export var node_path: NodePath
@export var method: StringName

@onready var _node: Node = get_node_or_null(node_path)


func attempt_method_call() -> void:
	if _node == null:
		attempt_failed.emit()
		return

	if not _node.has_method(method):
		attempt_failed.emit()
		return

	_node.call(method)
	attempt_succeeded.emit()
