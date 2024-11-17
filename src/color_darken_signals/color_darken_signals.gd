extends Node

signal darkened_color_changed(darkened_color: Color)

const _MIN_DARKEN = 0.0
const _MAX_DARKEN = 1.0
const _STEP = 0.1

@export var color: Color:
	set = set_color

@export_range(_MIN_DARKEN, _MAX_DARKEN, _STEP) var darken_amount: float:
	set = set_darken_amount

var darkened_color: Color:
	get = get_darkened_color,
	set = _set_darkened_color


func get_darkened_color() -> Color:
	return color.darkened(darken_amount)


func set_color(value: Color) -> void:
	color = value
	darkened_color_changed.emit(darkened_color)


func set_darken_amount(value: float) -> void:
	darken_amount = clampf(value, _MIN_DARKEN, _MAX_DARKEN)
	darkened_color_changed.emit(darkened_color)


func set_inverted_darken_amount(value: float) -> void:
	var clamped_value := clampf(value, _MIN_DARKEN, _MAX_DARKEN)
	set_darken_amount(_MAX_DARKEN - clamped_value)


func _set_darkened_color(_value: Color) -> void:
	pass  # Disallow directly setting darkened_color.
