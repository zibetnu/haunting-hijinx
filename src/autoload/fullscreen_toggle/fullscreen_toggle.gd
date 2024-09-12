extends Node


signal window_mode_requested(window_mode: DisplayServer.WindowMode)

const ACTION = "toggle_fullscreen"
const FULLSCREEN_MODE = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
const WINDOWED_MODE = DisplayServer.WINDOW_MODE_WINDOWED


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed(ACTION):
		return

	if DisplayServer.window_get_mode() == FULLSCREEN_MODE:
		window_mode_requested.emit(WINDOWED_MODE)

	else:
		window_mode_requested.emit(FULLSCREEN_MODE)
