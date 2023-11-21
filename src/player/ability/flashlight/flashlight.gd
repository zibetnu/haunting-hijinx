class_name Flashlight
extends Ability


const BEAM_FILE_PATH = "res://assets/flashlight/flashlight_beam_%s.png"
const BEAM_TEXTURES: Array[CompressedTexture2D] = [
	null,
	preload(BEAM_FILE_PATH % 1), preload(BEAM_FILE_PATH % 2), preload(BEAM_FILE_PATH % 3),
	preload(BEAM_FILE_PATH % 4), preload(BEAM_FILE_PATH % 5), preload(BEAM_FILE_PATH % 6),
	preload(BEAM_FILE_PATH % 7), preload(BEAM_FILE_PATH % 8), preload(BEAM_FILE_PATH % 9),
	preload(BEAM_FILE_PATH % 10), preload(BEAM_FILE_PATH % 11), preload(BEAM_FILE_PATH % 12),
	preload(BEAM_FILE_PATH % 13), preload(BEAM_FILE_PATH % 14), preload(BEAM_FILE_PATH % 15),
]
const CAST_LENGTHS: Array[int] = [0, 4, 5, 6, 7, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48]
const CAST_LONG_MAX_INDEX = 15
const CAST_LONG_MIN_INDEX = 5
const CAST_SHORT_MAX_INDEX = 4

@export_group("Battery")
@export var time := 43
@export var low_percentage := 0.5
@export_group("", "")

@export var action_name: String
@export var active_modifier: Modifier
@export var turn_speed := 2 * PI
@export var weak_to: DamageSource.Type

var battery := max_battery:
	set(value):
		battery = clampi(value, 0, max_battery)
		_update_frame()

var flashlight_rotation: float:
	get:
		return $RotationNode.rotation

	set(value):
		$RotationNode.rotation = value

var is_battery_low: bool:
	get:
		return percentage < low_percentage

var max_battery: int:
	get:
		return time * ProjectSettings.get_setting("physics/common/physics_ticks_per_second")

var percentage: float:
	get:
		return float(battery) / max_battery

	set(value):
		battery = roundi(max_battery * value)

var _frame: int:
	set(value):
		_frame = clampi(value, 0, BEAM_TEXTURES.size() - 1)
		for raycast in _raycast_parent.get_children():
			raycast.target_position.x = CAST_LENGTHS[_frame]

		$RotationNode/Light/FloorLight.texture = BEAM_TEXTURES[_frame]
		$RotationNode/Light/WallLight.texture = BEAM_TEXTURES[_frame]

var _powered: bool:
	set(value):
		_powered = value
		_beam.visible = _powered
		_body.frame = int(_powered)
		_light.visible = _powered
		if _powered:
			player.modifier_manager.add_modifier(active_modifier)

		else:
			player.modifier_manager.remove_modifier(active_modifier)

@onready var _beam := $RotationNode2/Beam
@onready var _body := $RotationNode2/Body
@onready var _light := $RotationNode/Light
@onready var _raycast_parent := $RotationNode/RayCasts


func _ready() -> void:
	super()
	player.revived.connect(_on_player_revived)
	for raycast in _raycast_parent.get_children():
		raycast.add_exception(player)


func _physics_process(delta: float) -> void:
	_update_direction(delta)
	if multiplayer.is_server():
		_powered = player.controller.is_action_pressed(action_name) and battery > 0

	if not _powered:
		return

	battery -= 1
	var all_colliders := []
	var all_colliders_and_points: Array[Dictionary] = []
	var all_repeat_raycasts := _raycast_parent.get_children()
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

	_beam.update_shape(all_colliders_and_points, all_repeat_raycasts)

	var processed_colliders := []
	for collider in all_colliders:
		if collider in processed_colliders:
			continue

		processed_colliders.append(collider)
		if not collider.has_method("take_damage"):
			continue

		collider.take_damage(DamageSource.from_light(1))


func take_damage(source: DamageSource) -> void:
	if source.damage_type == weak_to:
		battery = 0


func _on_player_revived() -> void:
	percentage = 0.75


func _on_player_state_machine_transitioned(state_name: String) -> void:
	var active := state_name in _state_names
	$CollisionShape2D.disabled = not active
	set_physics_process(active)
	if not active:
		_powered = false


func _update_frame() -> void:
	if is_battery_low:
		_frame = (ceil(CAST_SHORT_MAX_INDEX * (percentage / low_percentage)))

	else:
		_frame = (CAST_LONG_MIN_INDEX + ceil(
				(CAST_LONG_MAX_INDEX - CAST_LONG_MIN_INDEX)
				* ((percentage - low_percentage) / (1.0 - low_percentage))
		))


func _update_direction(delta: float) -> void:
	var look_vector := player.controller.look_vector
	if look_vector == Vector2.ZERO:
		return

	var angle_to := Vector2.from_angle(flashlight_rotation).angle_to(look_vector)
	flashlight_rotation += clamp(angle_to, -turn_speed * delta, turn_speed * delta)
