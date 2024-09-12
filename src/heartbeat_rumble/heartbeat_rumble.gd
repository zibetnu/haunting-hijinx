extends Node
## Mimics a heartbeat using gamepad vibration.


## Each value is the number of heartbeats per minute associated with the key.
enum HeartRate {
	NORMAL = 20,
	NERVOUS = 90,
	TERRIFIED = 180,
}

const DEVICE_INDEX = 0
const RUMBLE_DURATION = 0.2
const STRONG_MAGNITUDE = 0.0
const WEAK_MAGNITUDE = 0.1

const _MINUTE = 60

## The number of heartbeats per minute.
@export var heart_rate: HeartRate = HeartRate.NORMAL

var _time_elapsed := 0.0


func _process(delta: float) -> void:
	_time_elapsed += delta
	if _time_elapsed < _MINUTE / float(heart_rate):
		return

	_time_elapsed = 0.0
	Input.start_joy_vibration(
			DEVICE_INDEX,
			WEAK_MAGNITUDE,
			STRONG_MAGNITUDE,
			RUMBLE_DURATION
	)


func _exit_tree() -> void:
	Input.stop_joy_vibration(DEVICE_INDEX)


## Sets [enum heart_rate] to the [enum HeartRate] value pointed to by
## [param index] as if [enum HeartRate] was an [Array]. Has no effect if
## [param index] is out of range.
func set_heart_rate_from_index(index: int) -> void:
	if index < 0:
		return

	if index >= HeartRate.size():
		return

	heart_rate = HeartRate[HeartRate.keys()[index]]
