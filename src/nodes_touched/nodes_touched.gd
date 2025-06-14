extends Area2D

signal first_node_entered
signal last_node_exited
signal nodes_touched(count: int)

@export var count_group: StringName

var _nodes_touched := 0:
	set(value):
		if _nodes_touched == 0 and value > 0:
			first_node_entered.emit()

		elif _nodes_touched > 0 and value == 0:
			last_node_exited.emit()

		_nodes_touched = value
		nodes_touched.emit(_nodes_touched)


func _on_entered(node: Node) -> void:
	if node.is_in_group(count_group):
		_nodes_touched += 1


func _on_exited(node: Node) -> void:
	if node.is_in_group(count_group):
		_nodes_touched -= 1
