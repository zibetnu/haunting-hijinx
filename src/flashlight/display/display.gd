extends Node2D


signal flashlight_rotation_changed(flashlight_rotation: float)

const _LIGHT_FILE_PATH := "res://assets/flashlight/light_%s.png"
const _LIGHT_TEXTURES: Array[CompressedTexture2D] = [
	null,
	preload(_LIGHT_FILE_PATH % 1), preload(_LIGHT_FILE_PATH % 2), preload(_LIGHT_FILE_PATH % 3),
	preload(_LIGHT_FILE_PATH % 4), preload(_LIGHT_FILE_PATH % 5), preload(_LIGHT_FILE_PATH % 6),
	preload(_LIGHT_FILE_PATH % 7), preload(_LIGHT_FILE_PATH % 8), preload(_LIGHT_FILE_PATH % 9),
	preload(_LIGHT_FILE_PATH % 10), preload(_LIGHT_FILE_PATH % 11), preload(_LIGHT_FILE_PATH % 12),
	preload(_LIGHT_FILE_PATH % 13), preload(_LIGHT_FILE_PATH % 14), preload(_LIGHT_FILE_PATH % 15),
]

var powered: bool:
	set(value):
		powered = value
		_beam.visible = powered
		_light.visible = powered

var flashlight_rotation: float:
	get:
		return $RotationNode.rotation

	set(value):
		$RotationNode.rotation = value
		flashlight_rotation_changed.emit(flashlight_rotation)

var light_texture_index: int:
	set(value):
		light_texture_index = clampi(value, 0, _LIGHT_TEXTURES.size() - 1)
		$RotationNode/Light/FloorLight.texture = _LIGHT_TEXTURES[light_texture_index]
		$RotationNode/Light/WallLight.texture = _LIGHT_TEXTURES[light_texture_index]

@onready var _beam := $RotationNode2/Beam
@onready var _light := $RotationNode/Light


func set_collision_points(value: Array) -> void:
	_beam.polygon = [%BeamStartBottom.position, %BeamStartTop.position] + value


func set_powered(value: bool) -> void:
	powered = value


func set_flashlight_rotation(value: float) -> void:
	flashlight_rotation = value


func set_light_texture_index(value: int) -> void:
	light_texture_index = value
