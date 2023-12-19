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

@export var data: Resource:
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
		_body.frame = value

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

@onready var _beam := $IgnoreCanvasModulate/RotationNode3/_beam
@onready var _body := $RotationNode2/_body
@onready var _light := $RotationNode/Light


func _on_data_changed() -> void:
	if data.get("beam_points") is Array[Vector2]:
		beam_points = data.get("beam_points")

	if data.get("beam_visible") is bool:
		beam_visible = data.get("beam_visible")

	if data.get("body_frame") is int:
		body_frame = data.get("body_frame")

	if data.get("flashlight_rotation") is float:
		flashlight_rotation = data.get("flashlight_rotation")

	if data.get("light_frame") is int:
		light_frame = data.get("light_frame")

	if data.get("light_visible") is bool:
		light_visible = data.get("light_visible")
