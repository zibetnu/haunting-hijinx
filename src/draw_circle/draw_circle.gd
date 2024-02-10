extends Node2D


@export var radius := 10:
	set(value):
		radius = value
		queue_redraw()


func _draw() -> void:
	draw_arc(position, radius, 0, 2 * PI, 32, Color8(255, 255, 255, 63))
