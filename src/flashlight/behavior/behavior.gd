extends Area2D


signal battery_died
signal battery_undied
signal battery_lowed
signal battery_unlowed
signal beam_points_changed
signal cast_length_index_changed(index: int)
signal flashlight_rotation_changed(flashlight_rotation: float)
signal power_toggled(powered: bool)
signal powered_off
signal powered_on
signal powered_on_attempted

const CAST_LENGTHS: Array[int] = [0, 4, 5, 6, 7, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48]
const CAST_LONG_MAX_INDEX = 15
const CAST_LONG_MIN_INDEX = 5
const CAST_SHORT_MAX_INDEX = 4

@export_group("Battery", "battery")
@export var battery_low_percentage := 0.5
@export var battery_time := 43

@export_group("Damage", "damage")
@export var damage_deals: DamageSource
@export var damage_weak_to := DamageSource.Type.DARK

@export var data: FlashlightData:
	set(value):
		if data and data.changed.is_connected(_on_data_changed):
			data.changed.disconnect(_on_data_changed)

		data = value
		if data and not data.changed.is_connected(_on_data_changed):
			data.changed.connect(_on_data_changed)

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
		powered = battery > 0 and enabled and value
		power_toggled.emit(powered)
		match [was_powered, powered]:
			[false, true]:
				powered_on.emit()

			[true, false]:
				powered_off.emit()

		if value and battery == 0:
			powered_on_attempted.emit()

@export var target_rotation: float
@export var target_vector: Vector2:
	get:
		return Vector2.from_angle(target_rotation)

	set(value):
		if not value.is_zero_approx():
			target_rotation = value.angle()

@export var turn_speed := 2 * PI

var battery := max_battery:
	set(value):
		var was_battery_dead := battery == 0
		var was_battery_low := is_battery_low
		battery = clampi(value, 0, max_battery)
		match [was_battery_dead, battery == 0]:
			[false, true]:
				battery_died.emit()

			[true, false]:
				battery_undied.emit()

		if battery > 0:
			match [was_battery_low, is_battery_low]:
				[false, true]:
					battery_lowed.emit()

				[true, false]:
					battery_unlowed.emit()

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


func _physics_process(delta: float) -> void:
	rotation += clampf(
			angle_difference(rotation, target_rotation),
			-turn_speed * delta,
			turn_speed * delta
	)
	flashlight_rotation_changed.emit(rotation)

	if battery <= 0:
		powered = false
		return

	if not powered:
		return

	_update_cast_length()
	var all_colliders := []
	var all_colliders_and_points: Array[Dictionary] = []
	var all_repeat_raycasts := $RayCasts.get_children()
	for repeat_raycast in all_repeat_raycasts:
		var colliders_and_points = repeat_raycast.get_colliders_and_points()
		# Remove colliders that are past an object in the stop_flashlight group.
		for collider in colliders_and_points.colliders:
			if collider.is_in_group("stop_flashlight"):
				var resize_index: int = colliders_and_points.colliders.find(collider) + 1
				colliders_and_points.colliders.resize(resize_index)
				colliders_and_points.collision_points.resize(resize_index)
				break

		all_colliders += colliders_and_points.colliders
		all_colliders_and_points.append(colliders_and_points)

	var processed_colliders := []
	for collider in all_colliders:
		if collider in processed_colliders:
			continue

		processed_colliders.append(collider)
		if not collider.has_method("take_damage"):
			continue

		collider.take_damage(damage_deals)

	battery -= 1
	data.set_collision_points(_get_collision_points(all_colliders_and_points, all_repeat_raycasts))


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


func set_target_vector(value: Vector2) -> void:
	target_vector = value


func take_damage(source: DamageSource) -> void:
	if source.damage_type == damage_weak_to:
		battery = 0


func _get_collision_points(all_colliders_and_points: Array, raycasts: Array) -> Array[Vector2]:
	var rotated_collision_points: Array[Vector2] = []
	for i in range(mini(all_colliders_and_points.size(), raycasts.size())):
		rotated_collision_points.append(_get_rotated_collision_point(
				all_colliders_and_points[i], raycasts[i]
		))

	beam_points_changed.emit(rotated_collision_points)
	return rotated_collision_points


func _get_rotated_collision_point(colliders_and_points: Dictionary, raycast: RayCast2D) -> Vector2:
	if (
			colliders_and_points.collision_points.size() == 0
			# Assume that collider and point arrays have been resized to stop
			# at the first node that's in the stop_flashlight group.
			or not colliders_and_points.colliders[-1].is_in_group("stop_flashlight")
	):
		return (raycast.position
				+ Vector2(raycast.target_position.length(), 0).rotated(raycast.rotation)
		)

	var collision_point := raycast.to_local(colliders_and_points.collision_points[-1])
	return raycast.position + Vector2(collision_point.length(), 0).rotated(raycast.rotation)


func _update_cast_length() -> void:
	var index := 0
	if battery_percentage < battery_low_percentage:
		index = (ceil(
				CAST_SHORT_MAX_INDEX
				* (battery_percentage / battery_low_percentage)
		))

	else:
		index = (
				CAST_LONG_MIN_INDEX + ceil(
						(CAST_LONG_MAX_INDEX - CAST_LONG_MIN_INDEX)
						* (
								(battery_percentage - battery_low_percentage)
								/ (1.0 - battery_low_percentage)
						)
				)
		)

	data.collision_cast_length = CAST_LENGTHS[index]
	cast_length_index_changed.emit(index)


func _on_data_changed() -> void:
	for raycast: RayCast2D in $RayCasts.get_children():
		raycast.target_position.x = data.collision_cast_length
