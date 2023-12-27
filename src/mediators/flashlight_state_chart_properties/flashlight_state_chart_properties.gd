extends Node


@export var flashlight_data: FlashlightData:
	set(value):
		if flashlight_data and flashlight_data.changed.is_connected(_on_data_changed):
			flashlight_data.changed.disconnect(_on_data_changed)

		flashlight_data = value
		if flashlight_data and not flashlight_data.changed.is_connected(_on_data_changed):
			flashlight_data.changed.connect(_on_data_changed)

@export var state_chart: StateChart


func _set_expression_property(property_name: StringName, value: Variant) -> void:
	if state_chart:
		state_chart.set_expression_property(property_name, value)


func _on_data_changed() -> void:
	_set_expression_property("flashlight_battery_dead", flashlight_data.battery == 0)
	_set_expression_property(
			"flashlight_battery_low",
			flashlight_data.battery_percentage < flashlight_data.battery_low_percentage
	)
	_set_expression_property("flashlight_powered", flashlight_data.flashlight_powered)
