extends Node

signal min_value_changed(min_value: int)
signal max_value_changed(max_value: int)
signal scale_multiplier_changed(scale_multiplier: int)

const LABEL_FORMAT_STRING = "%sx"
const MIN_SCALE_MULTIPLIER = 1

@export var container: Container
@export var min_label: Label
@export var max_label: Label
@export var slider: Slider
@export var min_value: int = MIN_SCALE_MULTIPLIER:
	set = set_min_value
@export var max_value: int = MIN_SCALE_MULTIPLIER:
	set = set_max_value
@export var scale_multiplier: int = MIN_SCALE_MULTIPLIER:
	set = set_scale_multiplier

@onready var _debounce_timer: Timer = $DebounceTimer


func _ready() -> void:
	slider.value_changed.connect(_on_slider_value_changed)


func set_min_value(value: int) -> void:
	min_value = value
	min_value_changed.emit(min_label)
	if scale_multiplier < min_value:
		scale_multiplier = min_value

	if not is_node_ready():
		await ready

	slider.min_value = min_value
	min_label.text = LABEL_FORMAT_STRING % min_value


func set_max_value(value: int) -> void:
	max_value = value
	max_value_changed.emit(max_value)
	if scale_multiplier > max_value:
		scale_multiplier = max_value

	if not is_node_ready():
		await ready

	slider.max_value = max_value
	slider.tick_count = max_value
	max_label.text = LABEL_FORMAT_STRING % max_value


func set_scale_multiplier(value: int) -> void:
	scale_multiplier = clampi(value, min_value, max_value)
	scale_multiplier_changed.emit(scale_multiplier)
	if not is_node_ready():
		await ready

	slider.set_value_no_signal(scale_multiplier)


func _on_slider_value_changed(_value: float) -> void:
	_debounce_timer.start()


func _on_debounce_timer_timeout() -> void:
	scale_multiplier = int(slider.value)
