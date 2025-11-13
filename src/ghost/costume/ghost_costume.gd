@tool  # Allows editor to see results of setting frame_coord_x and y.
class_name GhostCostume
extends Node2D

@export_range(0.0, 1440.0, 0.6, "radians_as_degrees")
var rotation_speed: float = 2 * TAU

@export_range(-360.0, 360.0, 0.6, "radians_as_degrees")
var costume_rotation: float:
	set = set_costume_rotation

@export_range(-360.0, 360.0, 0.6, "radians_as_degrees")
var target_rotation: float:
	set = set_target_rotation

@export var frame_coord_x: int:
	get = get_frame_coord_x,
	set = set_frame_coord_x
@export var frame_coord_y: int:
	get = get_frame_coord_y,
	set = set_frame_coord_y
@export var lock_rotation := false:
	set = set_lock_rotation

@export_group("Hat", "hat")
@export var hat_array: Array[GhostHat]
@export var hat_index: int:
	set = set_hat_index

@onready var canvas_group: CanvasGroup = $CanvasGroup
@onready var sprite: Sprite2D = $CanvasGroup/MaterialParent/Sprite2D
@onready var hat: Sprite2D = %Hat
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var summon: AudioStreamPlayer2D = $Summon


func _ready() -> void:
	_apply_hat_index()


func _physics_process(delta: float) -> void:
	if lock_rotation:
		set_physics_process(false)
		return

	# Prefer clockwise rotation when flipping around.
	const BIAS = 0.001
	if PI - BIAS < absf(angle_difference(costume_rotation, target_rotation)):
		costume_rotation += BIAS

	costume_rotation =  rotate_toward(
			costume_rotation,
			target_rotation,
			rotation_speed * delta
	)
	set_physics_process(
			not is_equal_approx(costume_rotation, target_rotation)
	)


func get_frame_coord_x() -> int:
	return sprite.frame_coords.x


func get_frame_coord_y() -> int:
	return sprite.frame_coords.y


func play(value: String) -> void:
	animation_player.play(_get_first_partial_match(animation_player, value))


func set_costume_rotation(value: float) -> void:
	costume_rotation = value
	if lock_rotation:
		return

	if not is_node_ready():
		return

	_update_frame_coord_x()


func set_frame_coord_x(value: int) -> void:
	frame_coord_x = value
	if not is_node_ready():
		await ready

	sprite.frame_coords.x = clamp(value, 0, sprite.hframes - 1)
	hat.frame_coords.x = sprite.frame_coords.x


func set_hat_index(value: int) -> void:
	hat_index = 0 if hat_array.is_empty() else value % hat_array.size()
	if is_node_ready():
		_apply_hat_index()


func set_frame_coord_y(value: int) -> void:
	frame_coord_y = value
	if not is_node_ready():
		await ready

	sprite.frame_coords.y = clamp(value, 0, sprite.vframes - 1)
	hat.frame_coords.y = sprite.frame_coords.y


func set_lock_rotation(value: bool) -> void:
	var was_locked: bool = lock_rotation
	lock_rotation = value
	if was_locked and not lock_rotation:
		costume_rotation = Vector2.DOWN.angle()

	set_physics_process(not lock_rotation)


func set_target_rotation(value: float) -> void:
	target_rotation = value
	if lock_rotation:
		return

	if is_equal_approx(costume_rotation, target_rotation):
		return

	set_physics_process(true)


func _apply_hat_index() -> void:
	hat.texture = null if hat_array.is_empty() else hat_array[hat_index].texture


func _get_first_partial_match(
		player: AnimationPlayer,
		animation_name: String
) -> String:
	for animation_key in player.get_animation_list():
		if animation_name in animation_key:
			return animation_key

	return ""


func _on_current_animation_changed(animation_name: String) -> void:
	canvas_group.modulate = Color.WHITE
	canvas_group.position = Vector2.ZERO

	const SUMMON_NAME = "summon"
	if animation_name == SUMMON_NAME:
		summon.play()

	elif SUMMON_NAME not in animation_name:
		summon.stop()


func _update_frame_coord_x() -> void:
	frame_coord_x = posmod(
			roundi(costume_rotation / TAU * sprite.hframes),
			sprite.hframes
	)
