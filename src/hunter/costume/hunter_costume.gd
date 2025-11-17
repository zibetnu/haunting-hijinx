class_name HunterCostume
extends Node2D

enum Palette {
	YELLOW,
	GREEN,
	PURPLE,
	RED,
	BLUE,
}

const COSTUME_GROUP = &"hunter_costumes"
const PALETTE_PARAMETER = &"new_palette"
const PALETTE_TEXTURES: Dictionary[Palette, Texture2D] = {
	Palette.YELLOW: preload("uid://b1r4xdhw8pco3"),
	Palette.GREEN: preload("uid://vae6e0eh7xge"),
	Palette.PURPLE: preload("uid://cu33mq4g4e6ly"),
	Palette.RED: preload("uid://biqdpl1yys2eh"),
	Palette.BLUE: preload("uid://4l3a8ifjlff5"),
}
const HFRAME_COUNT = 16
const MIN_ROTATION = 0.0

@export var palette: Palette:
	set = set_palette

@export_group("Hat", "hat")
@export var hat_array: Array[HunterHat]
@export var hat_index: int:
	set = set_hat_index

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
@onready var material_parent: Node2D = %MaterialParent
@onready var legs: Sprite2D = %Legs
@onready var torso: Sprite2D = %Torso
@onready var arms: Sprite2D = %Arms
@onready var idle_no_flashlight: Sprite2D = %IdleNoFlashlight
@onready var hat: Sprite2D = %Hat


func _ready() -> void:
	_refresh_palettes()


func play(value: String) -> void:
	costume_current_animation = value
	hunter.play(_get_first_partial_match(hunter, value))


func play_effect(value: String) -> void:
	effects_current_animation = value
	effects.play(_get_first_partial_match(effects, value))


func set_costume_rotation(value: float) -> void:
	if costume_rotation == value:
		return

	costume_rotation = value
	if not is_node_ready():
		await ready

	var x_frame: int = roundi(remap(
			_normalize_rotation(costume_rotation),
			MIN_ROTATION, TAU,
			0, HFRAME_COUNT
	))
	x_frame %= HFRAME_COUNT
	for sprite: Sprite2D in [legs, torso, arms, hat, idle_no_flashlight]:
		sprite.frame_coords.x = x_frame


func set_hat_index(value: int) -> void:
	hat_index = 0 if hat_array.is_empty() else value % hat_array.size()
	if is_node_ready():
		_apply_hat_index()


func set_palette(value: Palette) -> void:
	palette = value
	if is_node_ready():
		_refresh_palettes()


func set_y_frame_arms(value: int) -> void:
	var clamped_value: int = clampi(value, 0, arms.vframes - 1)
	y_frame_arms = clamped_value
	arms.frame_coords.y = clamped_value


func set_y_frame_legs(value: int) -> void:
	var clamped_value: int = clampi(value, 0, legs.vframes - 1)
	y_frame_legs = clamped_value
	legs.frame_coords.y = clamped_value


func _apply_hat_index() -> void:
	var hat_data: HunterHat = hat_array[hat_index]
	hat.texture = null if hat_array.is_empty() else hat_data.texture

	var hat_material := hat.material as ShaderMaterial
	hat_material.set_shader_parameter(&"old_palette", hat_data.default_palette)
	if hat_data.palette_array.is_empty():
		hat_material.set_shader_parameter(&"new_palette", hat_data.default_palette)

	else:
		hat_material.set_shader_parameter(
				&"new_palette",
				hat_data.palette_array[palette % hat_data.palette_array.size()]
		)


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


func _refresh_palettes() -> void:
	(material_parent.material as ShaderMaterial).set_shader_parameter(
			PALETTE_PARAMETER,
			PALETTE_TEXTURES[palette]
	)
	_apply_hat_index()
