extends State


@export var exit_state: State
@export var wait_time := 2.0


func enter(_message := {}) -> void:
	if multiplayer.is_server():
		PauseManager.set_pause.rpc(true)
		$Timer.start(wait_time)


func exit() -> void:
	if multiplayer.is_server():
		PauseManager.set_pause.rpc(false)


func _on_timer_timeout() -> void:
	state_machine.transition_to.rpc(exit_state.name)
