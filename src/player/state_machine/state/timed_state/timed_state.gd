class_name TimedState
extends State


@export var exit_state: State
@export var state_time := 1.0

@onready var timer: Timer = $Timer


func enter(_message := {}) -> void:
	timer.start(state_time)


func exit() -> void:
	timer.stop()


func _on_timer_timeout() -> void:
	if state_machine.state != self:
		return

	if multiplayer.is_server():
		state_machine.transition_to.rpc(exit_state.name)
