extends Node


@export var flashlight_data: FlashlightData:
	set(value):
		if flashlight_data and flashlight_data.changed.is_connected(_on_data_changed):
			flashlight_data.changed.disconnect(_on_data_changed)

		flashlight_data = value
		if flashlight_data and not flashlight_data.changed.is_connected(_on_data_changed):
			flashlight_data.changed.connect(_on_data_changed)

@export var state_chart: StateChart

var _was_battery_dead := false
var _was_battery_low := false
var _was_flashlight_powered := false


func _send_event(event: StringName) -> void:
		if state_chart:
			state_chart.send_event(event)


func _on_data_changed() -> void:
	match [flashlight_data.battery == 0, _was_battery_dead]:
		[true, false]:
			_send_event("flashlight_battery_died")

		[false, true]:
			_send_event("flashlight_battery_undied")

	match [
			flashlight_data.battery_percentage < flashlight_data.battery_low_percentage,
			_was_battery_low
	]:
		[true, false]:
			_send_event("flashlight_battery_lowed")

		[false, true]:
			_send_event("flashlight_battery_unlowed")

	match [flashlight_data.flashlight_powered, _was_flashlight_powered]:
		[true, false]:
			_send_event("flashlight_powered")

		[false, true]:
			_send_event("flashlight_unpowered")

	_was_battery_dead = flashlight_data.battery == 0
	_was_battery_low = flashlight_data.battery_percentage < flashlight_data.battery_low_percentage
	_was_flashlight_powered = flashlight_data.flashlight_powered
