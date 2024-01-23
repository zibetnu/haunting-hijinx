extends Node


@export var active := false
@export var event: StringName
@export var state_chart: StateChart
@export var weak_to: DamageSource.Type


func take_damage(source: DamageSource) -> void:
	if not active:
		return

	if source.damage_type != weak_to:
		return

	if not state_chart:
		return

	state_chart.send_event(event)
