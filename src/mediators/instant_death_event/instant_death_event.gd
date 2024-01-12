extends Node


@export var damage_signals: DamageSignals:
	set(value):
		if damage_signals:
			damage_signals.damaged_by.disconnect(_on_damaged_by)

		damage_signals = value
		if damage_signals:
			damage_signals.damaged_by.connect(_on_damaged_by)

@export var state_chart: StateChart
@export var weak_to: DamageSource.Type


func _on_damaged_by(source: DamageSource) -> void:
	if source.damage_type != weak_to:
		return

	if not state_chart:
		return

	state_chart.send_event("died")
