extends Node

const ACTION = "toggle_fullscreen"
const FULLSCREEN_MODE = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
const WINDOWED_MODE = DisplayServer.WINDOW_MODE_WINDOWED

@onready var config_handler: ConfigHandler = $ConfigHandler


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed(ACTION):
		return

	if DisplayServer.window_get_mode() == FULLSCREEN_MODE:
		DisplayServer.window_set_mode(WINDOWED_MODE)

	else:
		DisplayServer.window_set_mode(FULLSCREEN_MODE)

	config_handler.save_value(DisplayServer.window_get_mode())


func _on_config_handler_loaded(value: Variant) -> void:
	DisplayServer.window_set_mode(value as int)


func _on_config_handler_load_failed() -> void:
	DisplayServer.window_set_mode(FULLSCREEN_MODE)
