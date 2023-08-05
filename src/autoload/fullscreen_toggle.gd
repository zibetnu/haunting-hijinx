extends Node


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS


func _input(_event: InputEvent) -> void:
	if not Input.is_action_just_pressed("toggle_fullscreen"):
		return

	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
