extends Node2D


var points: Array[Vector2] = []


func _draw() -> void:
	if points.size() >= 3:
		draw_colored_polygon(points, Color8(255, 255 , 255))


func set_points(value: Array[Vector2]) -> void:
	points = value
	queue_redraw()
