extends Node2D


# Not typed as Array[Vector2] due to a MultiplayerSynchronizer bug.
# See https://github.com/godotengine/godot/issues/74391.
var points: Array = []


func _draw() -> void:
	if points.size() < 3:
		return

	if Geometry2D.is_polygon_clockwise(points):
		return

	draw_colored_polygon(points, Color8(255, 255 , 255))


# value is not typed as Array[Vector2] due to a MultiplayerSynchronizer bug.
# See https://github.com/godotengine/godot/issues/74391.
func set_points(value: Array) -> void:
	points = value
	queue_redraw()
