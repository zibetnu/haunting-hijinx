extends Node2D


@export var color: Color
@export var point_count := 32
@export var radius := 10.0


func _draw() -> void:
	draw_arc(position, radius, 0, 2 * PI, point_count, color)
