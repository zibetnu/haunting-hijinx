class_name Level
extends Resource

@export var ghost_spawn_point: Vector2
@export var hunter_spawn_points: Array[Vector2]

@export_group("Camera Limits", "limit")
@export var limit_top_left: Vector2i
@export var limit_bottom_right: Vector2i

@export_storage var floor_data: PackedByteArray
@export_storage var wall_data: PackedByteArray
@export_storage var wall_top_data: PackedByteArray
@export_storage var wall_cap_data: PackedByteArray
@export_storage var prop_data: PackedByteArray
