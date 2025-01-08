extends Sprite2D

const COSTUME_GROUP = &"hunter_costumes"
const PALETTE_PARAMETER = &"new_palette"
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

@export_group("Palette", "palette")
@export var palette_auto_set := true
@export var palette_index: int:
	set = set_palette_index
@export var palette_array: Array[Texture2D]

@export_group("Y Frames", "y_frame")
@export var y_frame_arms: int:
	set = set_y_frame_arms
@export var y_frame_legs: int:
	set = set_y_frame_legs

@onready var effects: AnimationPlayer = $Effects
@onready var hunter: AnimationPlayer = $Hunter
@onready var material_parent: Node2D = %MaterialParent
@onready var legs: Sprite2D = %Legs
@onready var torso: Sprite2D = %Torso
@onready var arms: Sprite2D = %Arms


func _ready() -> void:
	if palette_auto_set:
		set_palette_index_from_group_index()


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
			MIN_ROTATION, TAU,
			0, HFRAME_COUNT
	))
	x_frame %= HFRAME_COUNT
	legs.frame_coords.x = x_frame
	torso.frame_coords.x = x_frame
	arms.frame_coords.x = x_frame


func set_palette_index(value: int) -> void:
	var palette_array_size: int = palette_array.size()
	palette_index = posmod(value, palette_array_size)
	if palette_array_size == 0:
		return

	(material_parent.material as ShaderMaterial).set_shader_parameter(
			PALETTE_PARAMETER,
			palette_array[palette_index]
	)


func set_palette_index_from_group_index() -> void:
	palette_index = get_tree().get_nodes_in_group(COSTUME_GROUP).find(self)


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


func _get_first_partial_match(
		player: AnimationPlayer,
		animation_name: String
) -> String:
	for animation_key in player.get_animation_list():
		if not animation_name in animation_key:
			continue

		return animation_key

	return ""
