extends Area2D


signal battery_died
signal battery_undied
signal battery_lowed
signal battery_unlowed
signal cast_length_index_changed(index: int)
signal collision_points_changed(points: Array[Vector2])
signal flashlight_rotation_changed(flashlight_rotation: float)
signal power_toggled(powered: bool)
signal powered_off
signal powered_on
signal powered_on_attempted

const CAST_LENGTHS: Array[int] = [0, 4, 5, 6, 7, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48]
const CAST_LONG_MAX_INDEX = 15
const CAST_LONG_MIN_INDEX = 5
const CAST_SHORT_MAX_INDEX = 4
const STOP_GROUP = "stop_flashlight"

@export var enabled := true:
	set(value):
		enabled = value
		set_deferred("monitorable", enabled)
		set_physics_process(enabled)
		if not enabled:
			powered = false

@export var powered: bool:
	set(value):
		var was_powered := powered
		powered = value and battery > 0 and enabled
		power_toggled.emit(powered)
		match [was_powered, powered]:
			[false, true]:
				powered_on.emit()

			[true, false]:
				powered_off.emit()

		if value and battery == 0:
			powered_on_attempted.emit()

@export_group("Battery", "battery")
@export_range(0, 1) var battery_low_percentage := 0.5
@export_range(0, 120, 0.1, "suffix:s") var battery_time := 43.0

@export_group("Damage", "damage")
@export var damage_deals: DamageSource
@export var damage_weak_to := DamageSource.Type.DARK

@export_group("Turning", "turning")
@export_range(0, 720, 0.1, "radians_as_degrees") var turning_speed_sec := 2 * PI

var battery := max_battery:
	set(value):
		var was_battery_dead := battery == 0
		var was_battery_low := is_battery_low
		battery = clampi(value, 0, max_battery)
		match [was_battery_dead, battery == 0]:
			[false, true]:
				battery_died.emit()
				powered = false

			[true, false]:
				battery_undied.emit()

		if battery > 0:
			match [was_battery_low, is_battery_low]:
				[false, true]:
					battery_lowed.emit()

				[true, false]:
					battery_unlowed.emit()

		_update_cast_length()

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

var is_battery_low: bool:
	get:
		return battery_percentage < battery_low_percentage

var target_rotation := 0.0

@onready var _repeat_raycasts: Array[RepeatRayCast2D] = [
	$RayCasts/RepeatRayCast2D,
	$RayCasts/RepeatRayCast2D2,
	$RayCasts/RepeatRayCast2D3,
]


func _physics_process(delta: float) -> void:
	_update_rotation(delta)
	if not powered:
		return

	var all_colliders: Array[Object] = []
	var all_colliders_and_points: Array[Dictionary] = []
	for repeat_raycast: RepeatRayCast2D in _repeat_raycasts:
		var colliders_and_points := repeat_raycast.get_colliders_and_points()
		# Remove colliders that are past an object in STOP_GROUP.
		for collider: Object in colliders_and_points.colliders:
			if collider.is_in_group(STOP_GROUP):
				var resize_index: int = colliders_and_points.colliders.find(collider) + 1
				colliders_and_points.colliders.resize(resize_index)
				colliders_and_points.collision_points.resize(resize_index)
				break

		all_colliders += colliders_and_points.colliders
		all_colliders_and_points.append(colliders_and_points)

	_damage_colliders(all_colliders)
	_emit_collision_points(all_colliders_and_points, _repeat_raycasts)
	battery -= 1


func disable() -> void:
	enabled = false


func enable() -> void:
	enabled = true


func power_off() -> void:
	powered = false


func power_on() -> void:
	powered = true


func set_battery_percentage(value: float) -> void:
	battery_percentage = value


func set_powered(value: bool) -> void:
	powered = value


func set_target_rotation(value: float) -> void:
	target_rotation = value


func set_target_rotation_from_vector(value: Vector2) -> void:
	if value.is_zero_approx():
		return

	target_rotation = value.angle()


func take_damage(source: DamageSource) -> void:
	if source.damage_type == damage_weak_to:
		battery = 0


func _damage_colliders(colliders: Array[Object]) -> void:
	var processed_colliders: Array[Object] = []
	for collider: Object in colliders:
		if collider in processed_colliders:
			continue

		processed_colliders.append(collider)
		if not collider.has_method("take_damage"):
			continue

		collider.take_damage(damage_deals)


func _emit_collision_points(all_colliders_and_points: Array, raycasts: Array) -> void:
	var rotated_collision_points: Array[Vector2] = []
	for i in range(mini(all_colliders_and_points.size(), raycasts.size())):
		rotated_collision_points.append(_get_rotated_collision_point(
				all_colliders_and_points[i], raycasts[i]
		))

	collision_points_changed.emit(rotated_collision_points)


func _get_rotated_collision_point(colliders_and_points: Dictionary, raycast: RayCast2D) -> Vector2:
	if (
			colliders_and_points.collision_points.size() == 0
			# Assume that collider and point arrays have been
			# resized to stop at the first node in STOP_GROUP.
			or not colliders_and_points.colliders[-1].is_in_group(STOP_GROUP)
	):
		return (raycast.position
				+ Vector2(raycast.target_position.length(), 0).rotated(raycast.rotation)
		)

	var collision_point := raycast.to_local(colliders_and_points.collision_points[-1])
	return raycast.position + Vector2(collision_point.length(), 0).rotated(raycast.rotation)


func _update_cast_length() -> void:
	var index := 0
	if is_battery_low:
		index = (ceil(
				CAST_SHORT_MAX_INDEX * battery_percentage / battery_low_percentage
		))

	else:
		index = (CAST_LONG_MIN_INDEX + ceil(
				(CAST_LONG_MAX_INDEX - CAST_LONG_MIN_INDEX)
				* (battery_percentage - battery_low_percentage)
				/ (1.0 - battery_low_percentage)
		))

	for raycast: RayCast2D in _repeat_raycasts:
		raycast.target_position.x = CAST_LENGTHS[index]

	cast_length_index_changed.emit(index)


func _update_rotation(delta: float) -> void:
	rotation += clampf(
			angle_difference(rotation, target_rotation),
			-turning_speed_sec * delta,
			turning_speed_sec * delta
	)
	flashlight_rotation_changed.emit(rotation)
