extends Node


signal changed(id: int)
signal changed_to_local()
signal changed_to_remote()

@export var id := 1:
	set = set_id


func set_id(value: int) -> void:
	id = value
	changed.emit(id)
	if id == multiplayer.get_unique_id():
		changed_to_local.emit()

	else:
		changed_to_remote.emit()
