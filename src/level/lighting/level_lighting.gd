class_name LevelLighting
extends Node2D

const MIN = 0.0
const MAX = 1.0

@export var base_color := Color.WHITE
@export var brightness := 1.0:
	set = set_brightness

@onready var canvas_modulate: CanvasModulate = $CanvasModulate


func _ready() -> void:
	set_brightness(
			GameConfig.get_value("display", "brightness", 0.126) as float
	)


func set_brightness(value: float) -> void:
	brightness = clampf(value, MIN, MAX)
	canvas_modulate.color = base_color.darkened(MAX - brightness)
