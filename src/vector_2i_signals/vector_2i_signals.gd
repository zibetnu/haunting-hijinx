extends Node


signal vector_changed(value: Vector2i)
signal vector_x_changed(value: int)
signal vector_y_changed(value: int)

@export var vector: Vector2i:
	set = set_vector

@export var vector_x: int:
	get = get_vector_x, set = set_vector_x

@export var vector_y: int:
	get = get_vector_y, set = set_vector_y


func get_vector_x() -> int:
	return vector.x


func get_vector_y() -> int:
	return vector.y


func set_vector(value: Vector2i) -> void:
	vector = value
	vector_changed.emit(vector)
	vector_x_changed.emit(vector.x)
	vector_y_changed.emit(vector.y)


func set_vector_x(value: int) -> void:
	vector.x = value


func set_vector_y(value: int) -> void:
	vector.y = value

