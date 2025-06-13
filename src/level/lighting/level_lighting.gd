class_name LevelLighting
extends Node2D

const MIN = 0.0
const MAX = 1.0

@export var base_color := Color.WHITE
@export var brightness := 1.0:
	set = set_brightness

@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var config_handler: ConfigHandler = $ConfigHandler


func _ready() -> void:
	config_handler.load_value()


func set_brightness(value: float) -> void:
	brightness = clampf(value, MIN, MAX)
	canvas_modulate.color = base_color.darkened(MAX - brightness)


func _on_config_handler_loaded(value: Variant) -> void:
	set_brightness(value as float)
