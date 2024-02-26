class_name FlashlightData
extends Node


signal changed()

@export_group("Collision", "collision")
@export var collision_cast_length := 0.0:
	set(value):
		if collision_cast_length == value:
			return

		collision_cast_length = value
		changed.emit()

@export var collision_points: Array[Vector2] = []


func set_collision_points(points: Array[Vector2]) -> void:
	if collision_points == points:
		return

	collision_points = points
	changed.emit()
