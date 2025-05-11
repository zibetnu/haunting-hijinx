class_name ConfigMenu
extends Control
# TODO: combine all scripts in this scene.

var vsync_config_handler := ConfigHandler.new()

@onready var vsync_option: OptionButtonID = %VSyncOption


func _ready() -> void:
	vsync_option.selected = DisplayServer.window_get_vsync_mode()
	vsync_config_handler.section = "display"
	vsync_config_handler.key = "vsync"
	vsync_config_handler.loaded.connect(vsync_option.select_id)
	vsync_config_handler.load_value()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			vsync_config_handler.queue_free()


func _on_vsync_option_id_selected(mode: DisplayServer.VSyncMode) -> void:
	DisplayServer.window_set_vsync_mode(mode)
	vsync_config_handler.save_value(mode)
