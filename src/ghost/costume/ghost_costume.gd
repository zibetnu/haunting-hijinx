@tool  # Allows editor to see results of setting frame_coord_x and y.
class_name GhostCostume
extends Node2D

const SOUTH_FRAME_COORD_X = 2

const _MIN_FRAME = 0
const _MIN_ROTATION = 0.0

@export var frame_coord_x: int:
	get = get_frame_coord_x,
	set = set_frame_coord_x
@export var frame_coord_y: int:
	get = get_frame_coord_y,
	set = set_frame_coord_y
@export var lock_rotation := false:
	set = set_lock_rotation

@onready var ghost: AnimationPlayer = $Ghost
@onready var sprite: Sprite2D = $ParentOffset/Sprite2D


func get_frame_coord_x() -> int:
	return sprite.frame_coords.x


func get_frame_coord_y() -> int:
	return sprite.frame_coords.y


func play(value: String) -> void:
	ghost.play(_get_first_partial_match(ghost, value))


func set_costume_rotation(value: float) -> void:
	if lock_rotation:
		return

	frame_coord_x = roundi(remap(
			fposmod(value, TAU),
			_MIN_ROTATION, TAU,
			_MIN_FRAME, sprite.hframes
	)) % sprite.hframes


func set_frame_coord_x(value: int) -> void:
	frame_coord_x = value
	if not is_node_ready():
		await ready

	sprite.frame_coords.x = clamp(value, _MIN_FRAME, sprite.hframes - 1)


func set_frame_coord_y(value: int) -> void:
	frame_coord_y = value
	if not is_node_ready():
		await ready

	sprite.frame_coords.y = clamp(value, _MIN_FRAME, sprite.vframes - 1)


func set_lock_rotation(value: bool) -> void:
	var was_locked: bool = lock_rotation
	lock_rotation = value
	if was_locked and not lock_rotation:
		frame_coord_x = SOUTH_FRAME_COORD_X


func _get_first_partial_match(
		player: AnimationPlayer,
		animation_name: String
) -> String:
	for animation_key in player.get_animation_list():
		if animation_name in animation_key:
			return animation_key

	return ""
