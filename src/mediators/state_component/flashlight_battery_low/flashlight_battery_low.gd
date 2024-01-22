extends StateComponent


@export var flashlight_data: FlashlightData

var active: bool:
	get:
		return active_state.active

var battery_low: bool:
	get:
		return flashlight_data.battery_percentage < flashlight_data.battery_low_percentage
