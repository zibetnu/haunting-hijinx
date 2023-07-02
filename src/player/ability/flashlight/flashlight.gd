extends Ability


signal battery_low

@export var action_name: String
@export var max_battery := 1200
@export var rotation_speed := PI / 60
@export var weak_to: DamageSource.Type
@export var low_percentage := 0.33
@export var battery := max_battery:
	set(value):
		battery = clamp(value, 0, max_battery)

var is_battery_low: bool:
	get:
		return float(battery) / max_battery < low_percentage

@onready var _max_beam_length = $Beam.size.x
@onready var _min_beam_cast_length = $RayCasts.get_children()[0].target_position.x


func _ready() -> void:
	super()
	player.revived.connect(_on_player_revived)
	for raycast in $RayCasts.get_children():
		raycast.add_exception(player)


func _physics_process(_delta: float) -> void:
	update_direction()

	if float(battery) / max_battery < low_percentage:
		battery_low.emit()

	$Beam.visible = player.controller.is_action_pressed(action_name) and battery > 0
	$Body.frame = int($Beam.visible)
	if not $Beam.visible:
		return

	battery -= 1
	$Beam.size.x = _max_beam_length * battery / max_battery
	for raycast in $RayCasts.get_children():
		raycast.target_position.x = _min_beam_cast_length + $Beam.size.x

	for raycast in $RayCasts.get_children():
		if not raycast.is_colliding():
			continue

		var collider = raycast.get_collider()
		if not collider.has_method("take_damage"):
			continue

		collider.take_damage(DamageSource.from_light(1))
		return


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
	battery = max_battery


func _on_player_state_machine_transitioned(state_name: String) -> void:
	var active := state_name in _state_names
	set_physics_process(active)
	if not active:
		$Beam.visible = false
		$Body.frame = 0
