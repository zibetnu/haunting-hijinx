extends Sprite2D


const HFRAME_COUNT = 16
const MIN_ROTATION = 0.0

@export_group("Costume", "costume")
@export var costume_current_animation: String:
	set = play
@export_range(-360, 360, 0.6, "radians_as_degrees") var costume_rotation: float:
	set = set_costume_rotation

@export_group("Effects", "effects")
@export var effects_current_animation: String:
	set = play_effect

@export_group("Y Frames", "y_frame")
@export var y_frame_arms: int:
	set = set_y_frame_arms
@export var y_frame_legs: int:
	set = set_y_frame_legs

@onready var effects: AnimationPlayer = $Effects
@onready var hunter: AnimationPlayer = $Hunter
@onready var legs: Sprite2D = $SubViewport/Legs
@onready var torso: Sprite2D = $SubViewport/Torso
@onready var arms: Sprite2D = $SubViewport/Arms


func play(value: String) -> void:
	costume_current_animation = value
	hunter.play(_get_first_partial_match(hunter, value))


func play_effect(value: String) -> void:
	effects_current_animation = value
	effects.play(_get_first_partial_match(effects, value))


func set_costume_rotation(value: float) -> void:
	costume_rotation = value
	var x_frame: int = roundi(remap(
			_normalize_rotation(costume_rotation),
			MIN_ROTATION, TAU, 0, HFRAME_COUNT
	))
	x_frame %= HFRAME_COUNT
	legs.frame_coords.x = x_frame
	torso.frame_coords.x = x_frame
	arms.frame_coords.x = x_frame


func set_y_frame_arms(value: int) -> void:
	var clamped_value: int = clampi(value, 0, arms.vframes - 1)
	y_frame_arms = clamped_value
	arms.frame_coords.y = clamped_value


func set_y_frame_legs(value: int) -> void:
	var clamped_value: int = clampi(value, 0, legs.vframes - 1)
	y_frame_legs = clamped_value
	legs.frame_coords.y = clamped_value


func _normalize_rotation(value: float) -> float:
	var reduced_rotation := fmod(value, TAU)
	if reduced_rotation < MIN_ROTATION:
		reduced_rotation += TAU

	return reduced_rotation


func _get_first_partial_match(player: AnimationPlayer,
							  animation_name: String) -> String:
	for animation_key in player.get_animation_list():
		if not animation_name in animation_key:
			continue

		return animation_key

	return ""
