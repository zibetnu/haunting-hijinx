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

@export var action_name: String
@export var active_modifier: Modifier
@export var battery_time := 43
@export var low_percentage := 0.5
@export var turn_speed := 2 * PI
@export var weak_to: DamageSource.Type

var battery := max_battery:
	set(value):
		battery = clampi(value, 0, max_battery)
		if not is_battery_low:
			_beam_frame = (
					5
					+ ceil((15 - 5) * ((percentage - low_percentage) / (1.0 - low_percentage)))
			)

		else:
			_beam_frame = (ceil(4 * (percentage / low_percentage)))

		for raycast in _raycast_parent.get_children():
			raycast.target_position.x = CAST_LENGTHS[_beam_frame]

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
		return (battery_time
				* ProjectSettings.get_setting("physics/common/physics_ticks_per_second"))

var percentage: float:
	get:
		return float(battery) / max_battery

	set(value):
		@warning_ignore("narrowing_conversion")
		battery = max_battery * value

var powered: bool:
	set(value):
		powered = value
		_body.frame = int(value)
		_light.visible = value

var _beam_frame: int:
	set(value):
		_beam_frame = clampi(value, 0, BEAM_TEXTURES.size() - 1)
		$RotationNode/Light/FloorLight.texture = BEAM_TEXTURES[_beam_frame]
		$RotationNode/Light/WallLight.texture = BEAM_TEXTURES[_beam_frame]

@onready var _raycast_parent := $RotationNode/RayCasts
@onready var _body := $RotationNode2/Body
@onready var _light := $RotationNode/Light


func _ready() -> void:
	super()
	player.revived.connect(_on_player_revived)
	for raycast in _raycast_parent.get_children():
		raycast.add_exception(player)


func _physics_process(delta: float) -> void:
	_update_direction(delta)

	var active := player.controller.is_action_pressed(action_name) and battery > 0
	if multiplayer.is_server():
		powered = active

	if not active:
		player.modifier_manager.remove_modifier(active_modifier)
		return

	player.modifier_manager.add_modifier(active_modifier)
	battery -= 1
	var all_colliders := []
	for repeat_raycast in _raycast_parent.get_children():
		var colliders: Array[Object] = repeat_raycast.get_colliders()

		# Remove colliders that are past an object in the stop_flashlight group.
		for collider in colliders:
			if collider.is_in_group("stop_flashlight"):
				colliders.resize(colliders.find(collider) + 1)
				break

		all_colliders += colliders

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
		powered = false


func _update_direction(delta: float) -> void:
	var look_vector := player.controller.look_vector
	if look_vector == Vector2.ZERO:
		return

	var angle_to := Vector2.from_angle(flashlight_rotation).angle_to(look_vector)
	flashlight_rotation += clamp(angle_to, -turn_speed * delta, turn_speed * delta)
