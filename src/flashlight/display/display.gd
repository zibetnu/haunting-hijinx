extends Node2D


const CAST_LONG_MAX_INDEX = 15
const CAST_LONG_MIN_INDEX = 5
const CAST_SHORT_MAX_INDEX = 4
const LIGHT_FILE_PATH := "res://assets/flashlight/light_%s.png"
const LIGHT_TEXTURES: Array[CompressedTexture2D] = [
	null,
	preload(LIGHT_FILE_PATH % 1), preload(LIGHT_FILE_PATH % 2), preload(LIGHT_FILE_PATH % 3),
	preload(LIGHT_FILE_PATH % 4), preload(LIGHT_FILE_PATH % 5), preload(LIGHT_FILE_PATH % 6),
	preload(LIGHT_FILE_PATH % 7), preload(LIGHT_FILE_PATH % 8), preload(LIGHT_FILE_PATH % 9),
	preload(LIGHT_FILE_PATH % 10), preload(LIGHT_FILE_PATH % 11), preload(LIGHT_FILE_PATH % 12),
	preload(LIGHT_FILE_PATH % 13), preload(LIGHT_FILE_PATH % 14), preload(LIGHT_FILE_PATH % 15),
]

@export var data: FlashlightData:
	set(value):
		if data and data.changed.is_connected(_on_data_changed):
			data.changed.disconnect(_on_data_changed)

		data = value
		if data and not data.changed.is_connected(_on_data_changed):
			data.changed.connect(_on_data_changed)

# Not typed as Array[Vector2] due to a MultiplayerSynchronizer bug.
# See https://github.com/godotengine/godot/issues/74391.
var beam_points: Array:
	get:
		return _beam.points

	set(value):
		_beam.set_points(value)

var flashlight_powered: bool:
	set(value):
		flashlight_powered = value
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


func _update_light_texture_index() -> void:
	var percentage := data.battery_percentage
	var low_perentage := data.battery_low_percentage
	if percentage < low_perentage:
		light_texture_index = (ceil(CAST_SHORT_MAX_INDEX * (percentage / low_perentage)))

	else:
		light_texture_index = (
				CAST_LONG_MIN_INDEX
				+ ceil(
						(CAST_LONG_MAX_INDEX - CAST_LONG_MIN_INDEX)
						* ((percentage - low_perentage) / (1.0 - low_perentage))
				)
		)


func _on_data_changed() -> void:
	beam_points = [%BeamStartBottom.position, %BeamStartTop.position] + data.collision_points
	flashlight_powered = data.flashlight_powered
	flashlight_rotation = data.flashlight_rotation
	_update_light_texture_index()
