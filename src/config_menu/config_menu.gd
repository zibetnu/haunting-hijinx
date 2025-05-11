class_name ConfigMenu
extends Control
# TODO: combine all scripts in this scene.

const DISPLAY_SECTION = "display"
const SCALE_KEY = "scale"

var vsync_config_handler := ConfigHandler.new()

@onready var save_timer: Timer = %SaveTimer
@onready var vsync_option: OptionButtonID = %VSyncOption
@onready var min_scale: Label = %MinScale
@onready var max_scale: Label = %MaxScale
@onready var scale_slider: HSlider = %ScaleSlider


func _ready() -> void:
	init_vsync_option()
	init_scale_slider()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			vsync_config_handler.queue_free()


func init_vsync_option() -> void:
	vsync_option.selected = DisplayServer.window_get_vsync_mode()
	vsync_config_handler.section = DISPLAY_SECTION
	vsync_config_handler.key = "vsync"
	vsync_config_handler.loaded.connect(vsync_option.select_id)
	vsync_config_handler.load_value()


func init_scale_slider() -> void:
	var max_value: int = WindowScaler.max_value
	max_scale.text = str(max_value)
	scale_slider.max_value = max_value
	scale_slider.tick_count = max_value

	var min_value: int = WindowScaler.min_value
	min_scale.text = str(min_value)
	scale_slider.min_value = min_value

	var value: float = GameConfig.get_value(
			DISPLAY_SECTION,
			SCALE_KEY,
			max_value
	)
	scale_slider.set_value_no_signal(value)

	_on_scale_debounce_timeout()


func _on_save_timer_timeout() -> void:
	GameConfig.save()


func _on_scale_debounce_timeout() -> void:
	var value: float = scale_slider.value
	WindowScaler.scale_multiplier = int(value)
	GameConfig.set_value(DISPLAY_SECTION, SCALE_KEY, value)
	save_timer.start()


func _on_vsync_option_id_selected(mode: DisplayServer.VSyncMode) -> void:
	DisplayServer.window_set_vsync_mode(mode)
	vsync_config_handler.save_value(mode)
