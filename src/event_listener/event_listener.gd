extends Node


signal listened_event_received()

@export var listen_for_event: StringName


func receive_event(event: StringName) -> void:
	if event == listen_for_event:
		listened_event_received.emit()
