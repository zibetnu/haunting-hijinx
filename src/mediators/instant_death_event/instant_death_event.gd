extends Node


@export var state_chart: StateChart
@export var weak_to: DamageSource.Type


func take_damage(source: DamageSource) -> void:
	if source.damage_type != weak_to:
		return

	if not state_chart:
		return

	state_chart.send_event("died")
