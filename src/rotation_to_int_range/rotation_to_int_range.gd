extends Node

signal range_value_changed(range_value: int)

const _MIN_RANGE_SIZE = 1
const _MIN_RANGE_VALUE = 0
const _MIN_ROTATION = 0.0
const _MAX_ROTATION = 2 * PI

@export var range_size: int = _MIN_RANGE_SIZE:
	set = set_range_size

@export var range_value: int = _MIN_RANGE_VALUE:
	set = set_range_value


func set_range_value(value: int) -> void:
	range_value = clampi(
			value,
			_MIN_RANGE_VALUE,
			_MIN_RANGE_VALUE + range_size - 1
	)
	range_value_changed.emit(range_value)


func set_range_value_from_rotation(rotation: float) -> void:
	var normalized_rotation: float = _normalize_rotation(rotation)
	var rotation_percent: float = normalized_rotation / _MAX_ROTATION
	var scaled_value := roundi(range_size * rotation_percent)
	range_value = _MIN_RANGE_VALUE + (scaled_value % range_size)


func set_range_size(value: int) -> void:
	if value < _MIN_RANGE_SIZE:
		range_size = _MIN_RANGE_SIZE
		return

	range_size = value

	# Ensure that range_value is in range of new range_size.
	range_value = range_value


func _normalize_rotation(rotation: float) -> float:
	var reduced_rotation := fmod(rotation, _MAX_ROTATION)
	if reduced_rotation < _MIN_ROTATION:
		reduced_rotation += _MAX_ROTATION

	return reduced_rotation
