extends Node


enum Mode {
	SERVER_ONLY,
	CLIENT_ONLY,
	BOTH,
}

@export var mode := Mode.SERVER_ONLY:
	set(value):
		mode = value
		_apply_mode()

@export var nodes: Array[Node]

var _original_process_modes := {}


func _ready() -> void:
	for node in nodes:
		_original_process_modes[node.get_path()] = node.process_mode

	_apply_mode()


func _apply_mode() -> void:
	match [multiplayer.is_server(), mode]:
		[false, Mode.SERVER_ONLY], [true, Mode.CLIENT_ONLY]:
			for node in nodes:
				node.process_mode = Node.PROCESS_MODE_DISABLED

		[true, Mode.SERVER_ONLY], [false, Mode.CLIENT_ONLY], [_, Mode.BOTH]:
			for node in nodes:
				node.process_mode = _original_process_modes.get(
						node.get_path(), node.process_mode
				)
