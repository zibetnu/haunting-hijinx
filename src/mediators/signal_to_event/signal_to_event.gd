extends Node


signal signal_received(event: StringName)

@export var emit_event: StringName


func receive_signal() -> void:
	signal_received.emit(emit_event)
