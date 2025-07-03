@tool  # Allows editor to see results of setting frame_coord_x and y.
class_name GhostCostume
extends Node2D

@export_range(-360.0, 360.0, 0.6, "radians_as_degrees")
var costume_rotation: float:
	set = set_costume_rotation

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
@onready var summon: AudioStreamPlayer2D = $Summon


func get_frame_coord_x() -> int:
	return sprite.frame_coords.x


func get_frame_coord_y() -> int:
	return sprite.frame_coords.y


func play(value: String) -> void:
	ghost.play(_get_first_partial_match(ghost, value))


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


func set_frame_coord_y(value: int) -> void:
	frame_coord_y = value
	if not is_node_ready():
		await ready

	sprite.frame_coords.y = clamp(value, 0, sprite.vframes - 1)


func set_lock_rotation(value: bool) -> void:
	var was_locked: bool = lock_rotation
	lock_rotation = value
	if was_locked and not lock_rotation:
		costume_rotation = Vector2.DOWN.angle()


func _get_first_partial_match(
		player: AnimationPlayer,
		animation_name: String
) -> String:
	for animation_key in player.get_animation_list():
		if animation_name in animation_key:
			return animation_key

	return ""


func _on_ghost_current_animation_changed(animation_name: String) -> void:
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
