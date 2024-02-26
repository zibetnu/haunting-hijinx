extends Node2D


const LIGHT_FILE_PATH := "res://assets/flashlight/light_%s.png"
const LIGHT_TEXTURES: Array[CompressedTexture2D] = [
	null,
	preload(LIGHT_FILE_PATH % 1), preload(LIGHT_FILE_PATH % 2), preload(LIGHT_FILE_PATH % 3),
	preload(LIGHT_FILE_PATH % 4), preload(LIGHT_FILE_PATH % 5), preload(LIGHT_FILE_PATH % 6),
	preload(LIGHT_FILE_PATH % 7), preload(LIGHT_FILE_PATH % 8), preload(LIGHT_FILE_PATH % 9),
	preload(LIGHT_FILE_PATH % 10), preload(LIGHT_FILE_PATH % 11), preload(LIGHT_FILE_PATH % 12),
	preload(LIGHT_FILE_PATH % 13), preload(LIGHT_FILE_PATH % 14), preload(LIGHT_FILE_PATH % 15),
]

# Not typed as Array[Vector2] due to a MultiplayerSynchronizer bug.
# See https://github.com/godotengine/godot/issues/74391.
var beam_points: Array:
	get:
		return _beam.points

	set(value):
		_beam.set_points(value)

var powered: bool:
	set(value):
		powered = value
		_beam.visible = value
		_body.frame = int(value)
		_light.visible = value

var flashlight_rotation: float:
	get:
		return $RotationNode.rotation

	set(value):
		$RotationNode.rotation = value

var light_texture_index: int:
	set(value):
		light_texture_index = clampi(value, 0, LIGHT_TEXTURES.size() - 1)
		$RotationNode/Light/FloorLight.texture = LIGHT_TEXTURES[light_texture_index]
		$RotationNode/Light/WallLight.texture = LIGHT_TEXTURES[light_texture_index]

@onready var _beam := $IgnoreCanvasModulate/RotationNode3/Beam
@onready var _body := $RotationNode2/Body
@onready var _light := $RotationNode/Light


func set_collision_points(value: Array) -> void:
	beam_points = [%BeamStartBottom.position, %BeamStartTop.position] + value


func set_powered(value: bool) -> void:
	powered = value


func set_flashlight_rotation(value: float) -> void:
	flashlight_rotation = value


func set_light_texture_index(value: int) -> void:
	light_texture_index = value
