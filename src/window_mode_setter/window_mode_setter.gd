extends Node

signal window_mode_changed(window_mode: DisplayServer.WindowMode)

const _WINDOWS_DISPLAY_SERVER_NAME = "Windows"


func set_window_mode(mode: DisplayServer.WindowMode) -> void:
	_apply_windows_maximized_workaround()
	DisplayServer.window_set_mode(mode)
	window_mode_changed.emit(DisplayServer.window_get_mode())


# On Windows, going fullscreen when the window is maximized makes it
# impossible to switch back to windowed mode. This workaround avoids the issue
# by changing the mode from maximized to windowed.
func _apply_windows_maximized_workaround() -> void:
	if DisplayServer.get_name() != _WINDOWS_DISPLAY_SERVER_NAME:
		return

	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_MAXIMIZED:
		return

	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
