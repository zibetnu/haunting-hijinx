extends Timer


## Default [param time_sec] for [method start_use_greater].
@export var greater_default_time := -1.0


## Starts timer using [member Timer.time_left] if it's greater than [param time_sec].
func start_use_greater(time_sec := greater_default_time) -> void:
	if greater_default_time < 0:
		time_sec = wait_time

	if time_sec > time_left:
		start(time_sec)

	else:
		start(time_left)
