extends Node


@export var source_node: Node
@export var source_variable: String


var vector: Vector2:
	get:
		return Vector2.from_angle(source_node.get(source_variable))
