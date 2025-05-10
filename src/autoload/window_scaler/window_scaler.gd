extends Node

signal min_value_changed(min_value: int)
signal max_value_changed(max_value: int)
signal scale_multiplier_changed(scale_multiplier: int)

const MIN_SCALE_MULTIPLIER = 1

@export var auto_set_limits := true:
	set = set_auto_set_limits
@export var min_value: int = MIN_SCALE_MULTIPLIER:
	set = set_min_value
@export var max_value: int = MIN_SCALE_MULTIPLIER:
	set = set_max_value
@export var auto_scale := true:
	set = set_auto_scale
@export var scale_multiplier: int = MIN_SCALE_MULTIPLIER:
	set = set_scale_multiplier

var base_size := Vector2i(
		ProjectSettings.get("display/window/size/viewport_width") as int,
		ProjectSettings.get("display/window/size/viewport_height") as int
)

@onready var window: Window = get_window()


func _ready() -> void:
	add_window_script()
	_on_window_size_changed()


func add_window_script() -> void:
	window.set_script(WindowSignals)
	var window_signals := window as WindowSignals
	window_signals.window_size_changed.connect(_on_window_size_changed)


func refresh_content_scale_size() -> void:
	var new_content_scale_size: Vector2i = window.size / scale_multiplier
	new_content_scale_size -= new_content_scale_size % 2
	if window.content_scale_size == new_content_scale_size:
		return

	window.content_scale_size = new_content_scale_size


func set_auto_set_limits(value: bool) -> void:
	auto_set_limits = value
	_update_min_value()
	_update_max_value()


func set_min_value(value: int) -> void:
	min_value = maxi(MIN_SCALE_MULTIPLIER, value)
	min_value_changed.emit(min_value)
	window.min_size = base_size * min_value


func set_max_value(value: int) -> void:
	max_value = maxi(MIN_SCALE_MULTIPLIER, value)
	max_value_changed.emit(max_value)


func set_auto_scale(value: bool) -> void:
	auto_scale = value
	_update_scale_multiplier()


func set_scale_multiplier(value: int) -> void:
	scale_multiplier = clampi(value, min_value, max_value)
	scale_multiplier_changed.emit(scale_multiplier)
	refresh_content_scale_size.call_deferred()


func _on_window_size_changed() -> void:
	if auto_set_limits:
		_update_min_value()
		_update_max_value()

	if auto_scale:
		_update_scale_multiplier()

	else:
		refresh_content_scale_size.call_deferred()


func _update_min_value() -> void:
	const BASE_DPI = 100
	@warning_ignore("integer_division")  # Decimal part should be discarded.
	min_value = DisplayServer.screen_get_dpi() / BASE_DPI


func _update_max_value() -> void:
	@warning_ignore("integer_division")  # Decimal part should be discarded.
	max_value = mini(window.size.x / base_size.x, window.size.y / base_size.y)


func _update_scale_multiplier() -> void:
	set_scale_multiplier(max_value)


class WindowSignals:
	extends Window

	## Emitted when the size of the window is changed, regardless of whether
	## the viewport size has changed.
	signal window_size_changed

	func _notification(what: int) -> void:
		if what == NOTIFICATION_WM_SIZE_CHANGED:
			window_size_changed.emit()
