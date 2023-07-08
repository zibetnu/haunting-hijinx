extends Node


@export var source_node: Node


var vector: Vector2:
	get:
		return Vector2.from_angle(source_node.get("rotation"))
