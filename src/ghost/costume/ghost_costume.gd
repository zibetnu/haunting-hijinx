@tool  # Allows editor to see results of setting frame_coord_x and y.
class_name GhostCostume
extends Node2D

const _MIN_FRAME = 0
const _MIN_ROTATION = 0.0

@export var frame_coord_x: int:
	set = set_frame_coord_x
@export var frame_coord_y: int:
	set = set_frame_coord_y

var _min_hframes: int
var _total_vframes := 0

@onready var ghost: AnimationPlayer = $Ghost
@onready var sprites: Array[Sprite2D] = [$Main, $Grab]


func _ready() -> void:
	_min_hframes = sprites[0].hframes
	for sprite in sprites:
		_min_hframes = mini(_min_hframes, sprite.hframes)
		_total_vframes += sprite.vframes


func play(value: String) -> void:
	ghost.play(_get_first_partial_match(ghost, value))


func set_costume_rotation(value: float) -> void:
	frame_coord_x = roundi(remap(
			fposmod(value, TAU),
			_MIN_ROTATION, TAU,
			_MIN_FRAME, _min_hframes
	)) % _min_hframes


func set_frame_coord_x(value: int) -> void:
	if not is_node_ready():
		await ready

	frame_coord_x = clamp(value, _MIN_FRAME, _min_hframes - 1)
	for sprite in sprites:
		sprite.frame_coords.x = frame_coord_x


func set_frame_coord_y(value: int) -> void:
	if not is_node_ready():
		await ready

	frame_coord_y = clamp(value, _MIN_FRAME, _total_vframes - 1)
	for sprite in sprites:
		sprite.hide()

	var relative_frame_coord_y: int = frame_coord_y
	var index := 0
	while relative_frame_coord_y >= sprites[index].vframes:
		relative_frame_coord_y -= sprites[index].vframes
		index += 1

	sprites[index].frame_coords.y = relative_frame_coord_y
	sprites[index].show()


func _get_first_partial_match(
		player: AnimationPlayer,
		animation_name: String
) -> String:
	for animation_key in player.get_animation_list():
		if animation_name in animation_key:
			return animation_key

	return ""
