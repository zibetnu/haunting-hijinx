extends Node


@export var alert: Alert
@export var aura_sense: Node


func _ready() -> void:
	if aura_sense.has_signal("sensed_intensity_changed"):
		aura_sense.sensed_intensity_changed.connect(_on_sensed_intensity_changed)


func _on_sensed_intensity_changed(intensity: int) -> void:
	if intensity <= 0:
			alert.alert_level = alert.AlertLevel.NONE

	elif intensity == 1:
		alert.alert_level = alert.AlertLevel.LOW

	else:
		alert.alert_level = alert.AlertLevel.HIGH
