extends Ability


@export var touched_state: State


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not multiplayer.is_server():
		return

	if not body is Player:
		return

	player.state_machine.transition_to.rpc(touched_state.name)


func _on_player_state_machine_transitioned(state_name: String) -> void:
	$Area2D.monitoring = state_name in _state_names
