extends Node2D

signal flashlight_rotation_changed(flashlight_rotation: float)
signal powered_off
signal powered_on

const PITCH_RANGE = 0.1
const POWERED_PITCH = 1.0
const UNPOWERED_PITCH = 0.8
const _LIGHT_FILE_PATH := "res://assets/flashlight/light_%s.png"

@export var light_textures: Array[CompressedTexture2D] = []

var powered: bool:
	set(value):
		var was_powered: bool = powered
		powered = value
		_beam.visible = powered
		_light.visible = powered
		if powered == was_powered:
			return

		(powered_on if powered else powered_off).emit()
		if _click.playing:
			return

		_click.set_pitch_scale(
				POWERED_PITCH if powered else UNPOWERED_PITCH
				+ randf_range(-PITCH_RANGE, PITCH_RANGE)
		)
		_click.play()

var flashlight_rotation: float:
	get:
		return $RotationNode.rotation

	set(value):
		$RotationNode.rotation = value
		flashlight_rotation_changed.emit(flashlight_rotation)

var light_texture_index: int:
	set(value):
		light_texture_index = clampi(value, 0, light_textures.size() - 1)
		$RotationNode/Light/FloorLight.texture = light_textures[light_texture_index]
		$RotationNode/Light/WallLight.texture = light_textures[light_texture_index]

@onready var _beam := $RotationNode2/Beam
@onready var _click: AudioStreamPlayer2D = $Click
@onready var _light := $RotationNode/Light


func set_collision_points(value: Array) -> void:
	_beam.polygon = [%BeamStartBottom.position, %BeamStartTop.position] + value


func set_powered(value: bool) -> void:
	powered = value


func set_flashlight_rotation(value: float) -> void:
	flashlight_rotation = value


func set_light_texture_index(value: int) -> void:
	light_texture_index = value
