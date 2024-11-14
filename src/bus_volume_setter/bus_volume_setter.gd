extends Node

signal volume_db_changed(volume_db: float)
signal volume_linear_changed(volume_linear: float)

@export var bus_name: StringName
@export var volume_db: float:
	get = get_volume_db,
	set = set_volume_db
@export var volume_linear: float:
	get = get_volume_linear,
	set = set_volume_linear


func get_volume_db() -> float:
	return AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus_name))


func get_volume_linear() -> float:
	return db_to_linear(volume_db)


func set_volume_db(value: float) -> void:
	AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index(bus_name),
			value
	)
	volume_db_changed.emit(value)
	volume_linear_changed.emit(db_to_linear(value))


func set_volume_linear(value: float) -> void:
	volume_db = linear_to_db(value)
