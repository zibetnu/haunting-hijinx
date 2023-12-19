extends Node2D


const BEAM_FILE_PATH = "res://assets/flashlight/flashlight_beam_%s.png"
const BEAM_TEXTURES: Array[CompressedTexture2D] = [
	null,
	preload(BEAM_FILE_PATH % 1), preload(BEAM_FILE_PATH % 2), preload(BEAM_FILE_PATH % 3),
	preload(BEAM_FILE_PATH % 4), preload(BEAM_FILE_PATH % 5), preload(BEAM_FILE_PATH % 6),
	preload(BEAM_FILE_PATH % 7), preload(BEAM_FILE_PATH % 8), preload(BEAM_FILE_PATH % 9),
	preload(BEAM_FILE_PATH % 10), preload(BEAM_FILE_PATH % 11), preload(BEAM_FILE_PATH % 12),
	preload(BEAM_FILE_PATH % 13), preload(BEAM_FILE_PATH % 14), preload(BEAM_FILE_PATH % 15),
]

@export var data: FlashlightData:
	set(value):
		if data and data.changed.is_connected(_on_data_changed):
			data.changed.disconnect(_on_data_changed)

		data = value
		if data and not data.changed.is_connected(_on_data_changed):
			data.changed.connect(_on_data_changed)

var beam_points: Array[Vector2]:
	get:
		return _beam.points

	set(value):
		_beam.set_points(value)

var beam_visible: bool:
	get:
		return _beam.visible

	set(value):
		_beam.visible = value

var body_frame: int:
	get:
		return _body.frame

	set(value):
		_body.frame = clampi(value, 0, _body.hframes * _body.vframes - 1)

var flashlight_rotation: float:
	get:
		return $RotationNode.rotation

	set(value):
		$RotationNode.rotation = value

var light_frame: int:
	set(value):
		light_frame = clampi(value, 0, BEAM_TEXTURES.size() - 1)
		$RotationNode/Light/FloorLight.texture = BEAM_TEXTURES[light_frame]
		$RotationNode/Light/WallLight.texture = BEAM_TEXTURES[light_frame]

var light_visible: bool:
	get:
		return _light.visible

	set(value):
		_light.visible = value

@onready var _beam := $IgnoreCanvasModulate/RotationNode3/Beam
@onready var _body := $RotationNode2/Body
@onready var _light := $RotationNode/Light


func _on_data_changed() -> void:
	beam_points = data.beam_points
	beam_visible = data.beam_visible
	body_frame = data.body_frame
	flashlight_rotation = data.flashlight_rotation
	light_frame = data.light_frame
	light_visible = data.light_visible
