class_name ConfigMenu
extends Control
# TODO: combine all scripts in this scene.

const DISPLAY_SECTION = "display"
const SCALE_KEY = "scale"

@export var first_button: Button

var vsync_config_handler := ConfigHandler.new()

@onready var save_timer: Timer = %SaveTimer
@onready var tab_container: TabContainer = %TabContainer
@onready var vsync_option: OptionButtonID = %VSyncOption
@onready var scale_container: PanelContainer = %ScaleContainer
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


func _on_visibility_changed() -> void:
	if not visible:
		return

	# Prevent button sound when setting initial tab.
	tab_container.set_block_signals(true)
	tab_container.set_current_tab(0)
	tab_container.set_block_signals(false)

	first_button.grab_focus()


func _on_vsync_option_id_selected(mode: DisplayServer.VSyncMode) -> void:
	DisplayServer.window_set_vsync_mode(mode)
	vsync_config_handler.save_value(mode)
