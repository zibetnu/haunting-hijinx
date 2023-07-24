extends Ability


const MAX_CAST_LENGTH = 24
const FLASHLIGHT_BODY_PERCENTAGE = 0.25

@export var action_name: String
@export var max_battery := 2580
@export var battery := max_battery:
	set(value):
		battery = clamp(value, 0, max_battery)
		$Sprite2D.material.set_shader_parameter(
				"percentage",
				FLASHLIGHT_BODY_PERCENTAGE + (1.0 - FLASHLIGHT_BODY_PERCENTAGE) * percentage
		)
		for raycast in $RayCasts.get_children():
			raycast.target_position.x = _min_cast_length + MAX_CAST_LENGTH * percentage

@export var low_percentage := 0.5
@export var rotation_speed: float = (
		2 * PI / ProjectSettings.get_setting("physics/common/physics_ticks_per_second")
)
@export var weak_to: DamageSource.Type

var is_battery_low: bool:
	get:
		return percentage < low_percentage

var percentage: float:
	get:
		return float(battery) / max_battery

@onready var _min_cast_length = $RayCasts.get_children()[0].target_position.x


func _ready() -> void:
	super()
	player.revived.connect(_on_player_revived)
	for raycast in $RayCasts.get_children():
		raycast.add_exception(player)


func _physics_process(_delta: float) -> void:
	update_direction()

	var active := player.controller.is_action_pressed(action_name) and battery > 0
	if multiplayer.is_server():
		$Sprite2D.frame = int(active)

	if not active:
		return

	battery -= 1
	var colliders := []
	for raycast in $RayCasts.get_children():
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


func update_direction() -> void:
	var look_vector := player.controller.look_vector
	if look_vector == Vector2.ZERO:
		return

	var angle_to := Vector2.from_angle(rotation).angle_to(look_vector)
	rotation += clamp(angle_to, -rotation_speed, rotation_speed)


func _on_player_revived() -> void:
	battery = max_battery * 0.75


func _get_colliders(raycast: RayCast2D) -> Array[Object]:
	var colliders: Array[Object] = []
	var exception_rids: Array[RID] = []
	while raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider.is_in_group("stop_flashlight"):
			break  # Don't get any colliders past something that stops the raycast.

		colliders.append(collider)
		var collider_rid := raycast.get_collider_rid()
		exception_rids.append(collider_rid)
		raycast.add_exception_rid(collider_rid)
		raycast.force_raycast_update()

	exception_rids.map(raycast.remove_exception_rid)
	return colliders


func _on_player_state_machine_transitioned(state_name: String) -> void:
	var active := state_name in _state_names
	set_physics_process(active)
	if multiplayer.is_server():
		$Sprite2D.frame = int(active)
