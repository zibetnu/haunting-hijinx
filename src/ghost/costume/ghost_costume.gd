@tool  # Allows editor to see results of setting frame_coord_x and y.
extends Sprite2D


const _MIN_FRAME = 0
const _MIN_ROTATION = 0.0

@export var frame_coord_x: int:
	get = get_frame_coord_x, set = set_frame_coord_x
@export var frame_coord_y: int:
	get = get_frame_coord_y, set = set_frame_coord_y

@onready var effects: AnimationPlayer = $Effects
@onready var ghost: AnimationPlayer = $Ghost


func get_frame_coord_x() -> int:
	return frame_coords.x


func get_frame_coord_y() -> int:
	return frame_coords.y


func play(value: String) -> void:
	ghost.play(_get_first_partial_match(ghost, value))


func play_effect(value: String) -> void:
	effects.play(_get_first_partial_match(effects, value))


func set_costume_rotation(value: float) -> void:
	frame_coord_x = roundi(remap(
			fposmod(value, TAU),
			_MIN_ROTATION, TAU,
			_MIN_FRAME, hframes
	)) % hframes


func set_frame_coord_x(value: int) -> void:
	frame_coords.x = clamp(value, _MIN_FRAME, hframes - 1)


func set_frame_coord_y(value: int) -> void:
	frame_coords.y = clamp(value, _MIN_FRAME, vframes - 1)


func _get_first_partial_match(player: AnimationPlayer,
							  animation_name: String) -> String:
	for animation_key in player.get_animation_list():
		if animation_name in animation_key:
			return animation_key

	return ""
