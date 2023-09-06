extends Node2D


@export var color: Color
@export var radius := 8.0


func _draw() -> void:
	draw_circle(position, radius, color)
