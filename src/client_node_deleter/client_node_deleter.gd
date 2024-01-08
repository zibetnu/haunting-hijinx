extends Node


@export var nodes: Array[Node]


func _ready() -> void:
	if multiplayer.is_server():
		return

	for node in nodes:
		node.queue_free()
