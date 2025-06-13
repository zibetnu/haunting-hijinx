class_name ConnectGroup
extends Node

@export var source: Node
@export var source_signal: StringName
@export var receiver_group: StringName
@export var receiver_method: StringName


func connect_group() -> void:
	for receiver: Node in get_tree().get_nodes_in_group(receiver_group):
		if not receiver.has_method(receiver_method):
			continue

		var receiver_callable := Callable(receiver, receiver_method)
		if source.is_connected(source_signal, receiver_callable):
			continue

		source.connect(source_signal, receiver_callable)
