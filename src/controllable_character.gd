class_name ControllableCharacter
extends CharacterBody2D

@export var controller: Controller:
	set = set_controller

var _pairs: Array[Pair] = []


# TODO: figure out why using the editor to clear this in an instance of a
# scene doesn't work. For example:
# - Hunter scene has its controller set to a child node.
# - Use editor to add hunter to another scene.
# - Use editor to clear the hunter's controller.
# - Observe that hunter acts as if the controller wasn't cleared.
func set_controller(value: Controller) -> void:
	_disconnect()
	controller = value
	_connect()


func _get_pairs() -> Array[Pair]:
	return []


func _connect() -> void:
	if not is_node_ready():
		await ready

	_pairs = _get_pairs()
	for pair in _pairs:
		pair.connect_pair()


func _disconnect() -> void:
	if not is_node_ready():
		await ready

	for pair in _pairs:
		pair.disconnect_pair()

	_pairs.clear()


class Pair:
	var source: Signal
	var callable: Callable

	@warning_ignore("shadowed_variable")
	func _init(source: Signal, callable: Callable) -> void:
		self.source = source
		self.callable = callable

	func connect_pair() -> void:
		if source.is_connected(callable):
			return

		source.connect(callable)

	func disconnect_pair() -> void:
		if not source.is_connected(callable):
			return

		source.disconnect(callable)
