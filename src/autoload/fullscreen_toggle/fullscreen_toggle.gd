extends Node


signal window_mode_changed(window_mode: DisplayServer.WindowMode)

const ACTION = "toggle_fullscreen"
const FULLSCREEN_MODE = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
const WINDOWED_MODE = DisplayServer.WINDOW_MODE_WINDOWED
const WINDOWS_DISPLAY_SERVER_NAME = "Windows"


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed(ACTION):
		return

	if DisplayServer.window_get_mode() == FULLSCREEN_MODE:
		set_window_mode(WINDOWED_MODE)

	else:
		set_window_mode(FULLSCREEN_MODE)


func set_window_mode(mode: DisplayServer.WindowMode) -> void:
	_apply_windows_maximized_workaround()
	DisplayServer.window_set_mode(mode)
	window_mode_changed.emit(DisplayServer.window_get_mode())


# On Windows, going fullscreen when the window is maximized will make it
# impossible to switch back to windowed mode. This workaround is used to set
# the mode to windowed before going fullscreen.
func _apply_windows_maximized_workaround() -> void:
	if DisplayServer.get_name() != WINDOWS_DISPLAY_SERVER_NAME:
		return

	if DisplayServer.window_get_mode() == FULLSCREEN_MODE:
		return

	if DisplayServer.window_get_mode() == WINDOWED_MODE:
		return

	DisplayServer.window_set_mode(WINDOWED_MODE)
