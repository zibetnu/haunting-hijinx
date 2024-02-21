class_name FlashlightData
extends Node


signal changed()
signal flashlight_rotation_changed(flashlight_rotation: float)

@export_group("Flashlight", "flashlight")
@export var flashlight_powered: bool:
	set(value):
		if flashlight_powered == value:
			return

		flashlight_powered = value
		changed.emit()

@export var flashlight_rotation := 0.0:
	set(value):
		if flashlight_rotation == value:
			return

		flashlight_rotation = value
		changed.emit()
		flashlight_rotation_changed.emit(flashlight_rotation)

@export var flashlight_turn_speed := 2 * PI:
	set(value):
		if flashlight_turn_speed == value:
			return

		flashlight_turn_speed = value
		changed.emit()

@export_group("Battery", "battery")
@export var battery_low_percentage := 0.5:
	set(value):
		if battery_low_percentage == value:
			return

		battery_low_percentage = value
		changed.emit()

@export var battery_time := 43:
	set(value):
		if battery_time == value:
			return

		battery_time = value
		changed.emit()

@export_group("Collision", "collision")
@export var collision_cast_length := 0.0:
	set(value):
		if collision_cast_length == value:
			return

		collision_cast_length = value
		changed.emit()

@export var collision_points: Array[Vector2] = []

@export_group("Damage", "damage")
@export var damage_deals: DamageSource:
	set(value):
		if damage_deals == value:
			return

		damage_deals = value
		changed.emit()

@export var damage_weak_to: DamageSource.Type:
	set(value):
		if damage_weak_to == value:
			return

		damage_weak_to = value
		changed.emit()

var battery := max_battery:
	set(value):
		if battery == value:
			return

		battery = clampi(value, 0, max_battery)
		changed.emit()

var battery_percentage: float:
	get:
		return float(battery) / max_battery

	set(value):
		battery = roundi(max_battery * clampf(value, 0, 1))

var max_battery: int:
	get:
		return battery_time * ProjectSettings.get_setting(
				"physics/common/physics_ticks_per_second"
		)


func set_collision_points(points: Array[Vector2]) -> void:
	if collision_points == points:
		return

	collision_points = points
	changed.emit()
