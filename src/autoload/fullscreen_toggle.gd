extends Node

const ACTION = "toggle_fullscreen"
const SECTION = "display"
const KEY = "window_mode"
const FULLSCREEN_MODE = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
const WINDOWED_MODE = DisplayServer.WINDOW_MODE_WINDOWED


func _ready() -> void:
	var saved: DisplayServer.WindowMode = GameConfig.get_value(
			SECTION,
			KEY,
			FULLSCREEN_MODE
	)
	DisplayServer.window_set_mode(saved)


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed(ACTION):
		return

	if DisplayServer.window_get_mode() == FULLSCREEN_MODE:
		DisplayServer.window_set_mode(WINDOWED_MODE)

	else:
		DisplayServer.window_set_mode(FULLSCREEN_MODE)

	GameConfig.set_value(
			SECTION,
			KEY,
			DisplayServer.window_get_mode()
	)
	GameConfig.save()

	var config_menu: ConfigMenu = get_tree().get_first_node_in_group(
			&"config_menu"
	)
	if config_menu != null:
		config_menu.init_window_mode_option()
