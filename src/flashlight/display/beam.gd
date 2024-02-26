extends Node2D


# Not typed as Array[Vector2] due to a MultiplayerSynchronizer bug.
# See https://github.com/godotengine/godot/issues/74391.
var points: Array = []:
	set(value):
		points = value
		queue_redraw()


func _draw() -> void:
	if points.size() < 3:
		return

	draw_colored_polygon(points, Color8(255, 255 , 255))


func set_points(value: Array) -> void:
	points = value
