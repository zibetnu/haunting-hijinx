extends Node


signal call_released

enum Mode {
	CLIENT_ONLY,
	SERVER_ONLY,
}

@export var hold_for: Mode

var _is_holding := false


func hold() -> void:
	if _is_holding:
		return

	_is_holding = true
	if multiplayer.is_server() and hold_for == Mode.CLIENT_ONLY:
		release()

	elif not multiplayer.is_server() and hold_for == Mode.SERVER_ONLY:
		release()


func release() -> void:
	if not _is_holding:
		return

	call_released.emit()
	_is_holding = false
