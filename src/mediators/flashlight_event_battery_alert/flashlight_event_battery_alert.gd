extends Node


@export var battery_alert: Node
@export var state_chart: StateChart:
	set(value):
		if state_chart:
			state_chart.event_received.disconnect(_on_event_received)

		state_chart = value
		if state_chart:
			state_chart.event_received.connect(_on_event_received)


func _on_event_received(event: StringName) -> void:
	match event:
		"flashlight_battery_died":
			if battery_alert.has_method("notify_dead"):
				battery_alert.notify_dead()

		"flashlight_battery_lowed":
			if battery_alert.has_method("notify_low"):
				battery_alert.notify_low()

		"flashlight_battery_undied", "flashlight_battery_unlowed":
			if battery_alert.has_method("notify_none"):
				battery_alert.notify_none()
