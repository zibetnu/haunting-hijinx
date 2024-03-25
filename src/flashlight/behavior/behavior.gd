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

@export var enabled := true:
	set(value):
		enabled = value
		set_deferred("monitorable", enabled)
		set_physics_process(enabled)
		if not enabled:
			powered = false

@export var powered: bool:
	get:
		return _powered

	set(value):
		if not is_node_ready():
			await ready

		_powered = value

@export_group("Battery", "battery")
@export_range(0, 1) var battery_low_percentage := 0.5
@export_range(0, 120, 0.1, "or_greater", "suffix:s") var battery_time := 43.0

@export_group("Damage", "damage")
@export var damage_deals: DamageSource
@export var damage_weak_to := DamageSource.Type.DARK

@export_group("Turning", "turning")
@export_range(0, 720, 0.1, "or_greater", "radians_as_degrees") var turning_speed_sec := 2 * PI
@export_range(-360, 360, 0.1, "radians_as_degrees") var turning_target_rotation: float:
	get:
		return target_rotation

	set(value):
		target_rotation = value

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

@onready var battery := max_battery:
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

@onready var _powered: bool:
	set(value):
		var was_powered := _powered
		_powered = value and battery > 0 and enabled
		match [was_powered, _powered]:
			[false, true]:
				power_toggled.emit(_powered)
				powered_on.emit()

			[true, false]:
				power_toggled.emit(_powered)
				powered_off.emit()

		if value and battery == 0:
			powered_on_attempted.emit()

@onready var _repeat_raycasts: Array[RepeatRayCast2D] = [
	$RayCasts/RepeatRayCast2D,
	$RayCasts/RepeatRayCast2D2,
	$RayCasts/RepeatRayCast2D3,
]


func _physics_process(delta: float) -> void:
	_update_rotation(delta)
	if not powered:
		return

	var colliders := []
	for repeat_raycast: RepeatRayCast2D in _repeat_raycasts:
		colliders.append_array(repeat_raycast.get_colliders())

	_damage_colliders(colliders)
	_emit_collision_points()
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


func _damage_colliders(colliders: Array) -> void:
	var processed_colliders := []
	for collider in colliders:
		if collider in processed_colliders:
			continue

		processed_colliders.append(collider)
		if not collider.has_method("take_damage"):
			continue

		collider.take_damage(damage_deals)


func _emit_collision_points() -> void:
	var collision_points: Array[Vector2] = []
	for raycast: RepeatRayCast2D in _repeat_raycasts:
		if raycast.is_colliding():
			collision_points.append(
					raycast.to_local(raycast.get_collision_point()).rotated(raycast.rotation)
			)

		else:
			collision_points.append(
					(raycast.position + raycast.target_position).rotated(raycast.rotation)
			)

	collision_points_changed.emit(collision_points)


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

	for raycast: RepeatRayCast2D in _repeat_raycasts:
		raycast.target_position.x = CAST_LENGTHS[index]

	cast_length_index_changed.emit(index)


func _update_rotation(delta: float) -> void:
	rotation += clampf(
			angle_difference(rotation, target_rotation),
			-turning_speed_sec * delta,
			turning_speed_sec * delta
	)
	flashlight_rotation_changed.emit(rotation)
