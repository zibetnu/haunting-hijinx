extends Node


@export var active := false
@export var event: StringName
@export var state_chart: StateChart


func _on_damage_taken() -> void:
	if not active:
		return

	if not state_chart:
		return

	state_chart.send_event(event)
