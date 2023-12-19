class_name FlashlightData
extends Node


signal changed()

const CAST_LENGTHS: Array[int] = [0, 4, 5, 6, 7, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48]
const CAST_LONG_MAX_INDEX = 15
const CAST_LONG_MIN_INDEX = 5
const CAST_SHORT_MAX_INDEX = 4

@export_group("Flashlight", "flashlight")
@export var flashlight_rotation := 0.0:
	set(value):
		flashlight_rotation = value
		changed.emit()

@export var flashlight_turn_speed := 2 * PI

@export_group("Battery", "battery")
@export var battery_time := 43
@export var battery_low_percentage := 0.5

@export_group("Beam", "beam")
@export var beam_points: Array[Vector2] = []
@export var beam_visible := false:
	set(value):
		beam_visible = value
		changed.emit()

@export_group("Body", "body")
@export var body_frame := 0:
	set(value):
		body_frame = value
		changed.emit()

@export_group("Light", "light")
@export var light_frame := 0:
	set(value):
		light_frame = value
		changed.emit()

@export var light_visible := false:
	set(value):
		light_visible = value
		changed.emit()

@export_group("Damage", "damage")
@export var damage_deals: DamageSource
@export var damage_weak_to: DamageSource.Type

var battery := max_battery:
	set(value):
		battery = clampi(value, 0, max_battery)

var max_battery: int:
	get:
		return battery_time * ProjectSettings.get_setting(
				"physics/common/physics_ticks_per_second"
		)

var percentage: float:
	get:
		return float(battery) / max_battery

	set(value):
		battery = roundi(max_battery * clampf(value, 0, 1))


func set_beam_points(points: Array[Vector2]) -> void:
	beam_points = points
	changed.emit()
