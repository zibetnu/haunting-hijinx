extends Ability


@export var action_name: String
@export var enter_state: State
@export var exit_state: State


func _on_player_state_machine_transitioned(state_name: String) -> void:
	set_process(
			multiplayer.is_server()
			and state_name in _state_names
	)


func _process(_delta: float) -> void:
	if (
			player.state_machine.state != enter_state
			and player.controller.is_action_pressed(action_name)
	):
		player.state_machine.transition_to.rpc(enter_state.name)

	elif (
			player.state_machine.state == enter_state
			and not player.controller.is_action_pressed(action_name)
	):
		player.state_machine.transition_to.rpc(exit_state.name)
