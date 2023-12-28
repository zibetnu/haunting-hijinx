extends Node


@export var signal_name: StringName
@export var signal_source: Node:
	set(value):
		if signal_source:
			_disconnect_signal()

		signal_source = value
		if signal_source:
			_connect_signal()

@export var state_chart: StateChart


func _connect_signal() -> void:
	if not signal_source.has_signal(signal_name):
		return

	if signal_source.get(signal_name).is_connected(_on_signal_emitted):
		return

	signal_source.connect(signal_name, _on_signal_emitted)


func _disconnect_signal() -> void:
	if not signal_source.has_signal(signal_name):
		return

	if not signal_source.get(signal_name).is_connected(_on_signal_emitted):
		return

	signal_source.disconnect(signal_name, _on_signal_emitted)


func _on_signal_emitted() -> void:
	if state_chart:
		state_chart.send_event(signal_name)
