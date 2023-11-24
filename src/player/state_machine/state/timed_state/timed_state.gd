class_name TimedState
extends State


@export var exit_state: State
@export var exit_message: Dictionary
@export var state_time := 1.0

var _remaining_time := 0.0

@onready var timer: Timer = $Timer


func enter(message := {}) -> void:
	if message.get("use_remaining", false):
		timer.start(max(message.get("state_time", state_time), timer.time_left))
		return

	timer.start(message.get("state_time", state_time))


func exit() -> void:
	_remaining_time = timer.time_left
	timer.stop()


func _on_timer_timeout() -> void:
	if state_machine.state != self:
		return

	if multiplayer.is_server():
		state_machine.transition_to.rpc(exit_state.name, exit_message)
