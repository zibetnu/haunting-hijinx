class_name ConfigMenu
extends Control
# TODO: combine all scripts in this scene.

const AUDIO_SECTION = "audio"
const MASTER_KEY = "master"
const DISPLAY_SECTION = "display"
const BRIGHTNESS_KEY = "brightness"
const SCALE_KEY = "scale"
const VSYNC_KEY = "vsync"
const WINDOW_MODE_KEY = "window_mode"

@export var first_button: Button

@onready var save_timer: Timer = %SaveTimer
@onready var window_mode_option: OptionButtonID = %WindowModeOption
@onready var vsync_option: OptionButtonID = %VSyncOption
@onready var scale_container: PanelContainer = %ScaleContainer
@onready var min_scale: Label = %MinScale
@onready var max_scale: Label = %MaxScale
@onready var brightness_slider: Slider = %BrightnessSlider
@onready var scale_slider: Slider = %ScaleSlider
@onready var master_bus_slider: Slider = %MasterBusSlider
@onready var music_bus_slider: Slider = %MusicBusSlider
@onready var effects_bus_slider: Slider = %EffectsBusSlider


func _ready() -> void:
	init_window_mode_option()
	init_vsync_option()
	init_slider(brightness_slider, DISPLAY_SECTION, BRIGHTNESS_KEY, 0.126)
	init_scale_slider()
	init_slider(master_bus_slider, AUDIO_SECTION, MASTER_KEY, 1.0)
	init_slider(music_bus_slider, AUDIO_SECTION, "music", 1.0)
	init_slider(effects_bus_slider, AUDIO_SECTION, "effects", 1.0)


func init_window_mode_option() -> void:
	var saved: int = GameConfig.get_value(
			DISPLAY_SECTION,
			WINDOW_MODE_KEY,
			DisplayServer.window_get_mode()
	)
	window_mode_option.select_id(saved)


func init_vsync_option() -> void:
	var saved: int = GameConfig.get_value(
			DISPLAY_SECTION,
			VSYNC_KEY,
			DisplayServer.window_get_vsync_mode()
	)
	vsync_option.selected = saved


func init_slider(
		slider: Slider,
		section: String,
		key: String,
		default: float
) -> void:
	slider.value_changed.connect(
			_on_slider_value_changed.bind(section, key)
	)
	var saved: float = GameConfig.get_value(section, key, default)
	slider.set_value_no_signal(saved)


func init_scale_slider() -> void:
	# Prevent button sound when setting initial values.
	scale_slider.set_block_signals(true)

	const LABEL_TEXT_TEMPLATE = "%sx"

	var max_value: int = WindowScaler.max_value
	max_scale.text = LABEL_TEXT_TEMPLATE % max_value
	scale_slider.max_value = max_value
	scale_slider.tick_count = max_value

	var min_value: int = WindowScaler.min_value
	min_scale.text = LABEL_TEXT_TEMPLATE % min_value
	scale_slider.min_value = min_value

	scale_slider.value = GameConfig.get_value(
			DISPLAY_SECTION,
			SCALE_KEY,
			max_value
	)
	scale_slider.set_block_signals(false)

	scale_container.visible = min_value < max_value
	_on_scale_debounce_timeout()


func _on_save_timer_timeout() -> void:
	GameConfig.save()


func _on_scale_debounce_timeout() -> void:
	var value: float = scale_slider.value
	WindowScaler.scale_multiplier = int(value)
	GameConfig.set_value(DISPLAY_SECTION, SCALE_KEY, value)
	save_timer.start()


func _on_window_mode_selected(value: DisplayServer.WindowMode) -> void:
	DisplayServer.window_set_mode(value)
	GameConfig.set_value(DISPLAY_SECTION, WINDOW_MODE_KEY, value)
	save_timer.start()


func _on_visibility_changed() -> void:
	if not visible:
		return

	first_button.grab_focus()


func _on_vsync_option_id_selected(mode: DisplayServer.VSyncMode) -> void:
	DisplayServer.window_set_vsync_mode(mode)
	GameConfig.set_value(DISPLAY_SECTION, VSYNC_KEY, mode)
	save_timer.start()


func _on_brightness_slider_value_changed(value: float) -> void:
	get_tree().call_group(&"level_lighting", &"set_brightness", value)


func _on_slider_value_changed(value: float, section: String, key: String) -> void:
	GameConfig.set_value(section, key, value)
	save_timer.start()
