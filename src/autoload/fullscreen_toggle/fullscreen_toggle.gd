extends Node


signal window_mode_changed(window_mode: DisplayServer.WindowMode)

const ACTION = "toggle_fullscreen"
const FULLSCREEN_MODE = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
const WINDOWED_MODE = DisplayServer.WINDOW_MODE_WINDOWED


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed(ACTION):
		return

	if DisplayServer.window_get_mode() == FULLSCREEN_MODE:
		set_window_mode(WINDOWED_MODE)

	else:
		set_window_mode(FULLSCREEN_MODE)


func set_window_mode(mode: DisplayServer.WindowMode) -> void:
	DisplayServer.window_set_mode(mode)
	window_mode_changed.emit(DisplayServer.window_get_mode())
