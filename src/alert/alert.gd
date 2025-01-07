class_name Alert
extends Control

signal alert_level_changed(alert_level: AlertLevel)
signal alerted_none
signal alerted_low
signal alerted_high

enum AlertLevel {
	NONE,
	LOW,
	HIGH,
}

@export var alert_level: AlertLevel:
	set(value):
		alert_level = value
		alert_level_changed.emit(alert_level)
		match alert_level:
			AlertLevel.NONE:
				alerted_none.emit()

			AlertLevel.LOW:
				alerted_low.emit()

			AlertLevel.HIGH:
				alerted_high.emit()

		_update_animation()

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func set_alert_level(value: AlertLevel) -> void:
	alert_level = value


func set_alert_level_from_int(value: int) -> void:
	if value <= 0:
		alert_level = AlertLevel.NONE

	elif value == 1:
		alert_level = AlertLevel.LOW

	else:
		alert_level = AlertLevel.HIGH


func _update_animation() -> void:
	if not is_node_ready():
		await ready

	match alert_level:
		AlertLevel.NONE:
			animation_player.play("RESET")

		AlertLevel.LOW:
			animation_player.play("alert_low")

		AlertLevel.HIGH:
			animation_player.play("alert_high")
