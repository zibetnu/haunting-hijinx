extends Node

signal max_value_changed(max_value: int)
signal scale_multiplier_changed(scale_multiplier: int)

const MIN_SCALE_MULTIPLIER = 1

@export var max_value: int = MIN_SCALE_MULTIPLIER:
	set = set_max_value
@export var scale_multiplier: int = MIN_SCALE_MULTIPLIER:
	set = set_scale_multiplier

var base_size := Vector2i(
		ProjectSettings.get("display/window/size/viewport_width") as int,
		ProjectSettings.get("display/window/size/viewport_height") as int
)

@onready var window: Window = get_window()


func _ready() -> void:
	add_window_script()
	init_max_value()
	scale_multiplier = GameConfig.get_value("display", "scale", scale_multiplier)


func init_max_value() -> void:
	var screen_size: Vector2i = DisplayServer.screen_get_size()
	@warning_ignore("integer_division")  # Decimal part should be discarded.
	max_value = mini(screen_size.x / base_size.x, screen_size.y / base_size.y)


func add_window_script() -> void:
	window.set_script(WindowSignals)
	var window_signals := window as WindowSignals
	window_signals.window_size_changed.connect(
			refresh_content_scale_size,
			CONNECT_DEFERRED
	)


func refresh_content_scale_size() -> void:
	@warning_ignore("integer_division")
	var new_content_scale_size: Vector2i = window.size / scale_multiplier
	new_content_scale_size -= new_content_scale_size % 2
	if window.content_scale_size == new_content_scale_size:
		return

	window.content_scale_size = new_content_scale_size


func set_max_value(value: int) -> void:
	max_value = maxi(MIN_SCALE_MULTIPLIER, value)
	max_value_changed.emit(max_value)


func set_scale_multiplier(value: int) -> void:
	scale_multiplier = clampi(value, MIN_SCALE_MULTIPLIER, max_value)
	scale_multiplier_changed.emit(scale_multiplier)
	window.min_size = base_size * scale_multiplier
	refresh_content_scale_size.call_deferred()


class WindowSignals:
	extends Window

	## Emitted when the size of the window is changed, regardless of whether
	## the viewport size has changed.
	signal window_size_changed

	func _notification(what: int) -> void:
		if what == NOTIFICATION_WM_SIZE_CHANGED:
			window_size_changed.emit()
