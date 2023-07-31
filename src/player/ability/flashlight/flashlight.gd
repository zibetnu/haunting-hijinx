extends Ability


const FLASHLIGHT_BODY_PERCENTAGE = 0.25
const MAX_CAST_LENGTH = 24

@export var action_name: String
@export var active_modifier: Modifier
@export var battery_time := 43
@export var low_percentage := 0.5
@export var turn_speed := 2 * PI
@export var weak_to: DamageSource.Type

var battery := max_battery:
	set(value):
		battery = clamp(value, 0, max_battery)
		_sprite.material.set_shader_parameter("percentage",
				FLASHLIGHT_BODY_PERCENTAGE + (1.0 - FLASHLIGHT_BODY_PERCENTAGE) * percentage)
		for raycast in _raycast_parent.get_children():
			raycast.target_position.x = _min_cast_length + MAX_CAST_LENGTH * percentage

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

@onready var _min_cast_length = $RotationNode/RayCasts.get_children()[0].target_position.x
@onready var _raycast_parent := $RotationNode/RayCasts
@onready var _rotation_node := $RotationNode
@onready var _sprite := $RotationNode/Sprite2D


func _ready() -> void:
	super()
	player.revived.connect(_on_player_revived)
	for raycast in _raycast_parent.get_children():
		raycast.add_exception(player)


func _physics_process(delta: float) -> void:
	_update_direction(delta)

	var active := player.controller.is_action_pressed(action_name) and battery > 0
	if multiplayer.is_server():
		_sprite.frame = int(active)

	if not active:
		player.modifier_manager.remove_modifier(active_modifier)
		return

	player.modifier_manager.add_modifier(active_modifier)
	battery -= 1
	var colliders := []
	for raycast in _raycast_parent.get_children():
		colliders += _get_colliders(raycast)

	var processed_colliders := []
	for collider in colliders:
		if collider in processed_colliders:
			continue

		processed_colliders.append(collider)
		if not collider.has_method("take_damage"):
			continue

		collider.take_damage(DamageSource.from_light(1))


func take_damage(source: DamageSource) -> void:
	if source.damage_type == weak_to:
		battery = 0


func _get_colliders(raycast: RayCast2D) -> Array[Object]:
	var colliders: Array[Object] = []
	var exception_rids: Array[RID] = []
	while raycast.is_colliding():
		var collider = raycast.get_collider()
		colliders.append(collider)
		if collider.is_in_group("stop_flashlight"):
			break  # Don't get any colliders past something that stops the raycast.

		var collider_rid := raycast.get_collider_rid()
		exception_rids.append(collider_rid)
		raycast.add_exception_rid(collider_rid)
		raycast.force_raycast_update()

	exception_rids.map(raycast.remove_exception_rid)
	return colliders


func _on_player_revived() -> void:
	percentage = 0.75


func _on_player_state_machine_transitioned(state_name: String) -> void:
	var active := state_name in _state_names
	$CollisionShape2D.disabled = not active
	set_physics_process(active)
	if not active:
		_sprite.frame = 0


func _update_direction(delta: float) -> void:
	var look_vector := player.controller.look_vector
	if look_vector == Vector2.ZERO:
		return

	var angle_to := Vector2.from_angle(_rotation_node.rotation).angle_to(look_vector)
	_rotation_node.rotation += clamp(angle_to, -turn_speed * delta, turn_speed * delta)
