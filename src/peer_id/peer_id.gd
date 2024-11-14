extends Node

signal changed(id: int)
signal changed_to_local
signal changed_to_remote

@export var id := 1:
	set = set_id

@export var emit_on_ready := true


func _ready() -> void:
	if emit_on_ready:
		set_id(id)  # Set to current value again so signals will emit.


func set_id(value: int) -> void:
	id = value
	changed.emit(id)
	if id == multiplayer.get_unique_id():
		changed_to_local.emit()

	else:
		changed_to_remote.emit()
