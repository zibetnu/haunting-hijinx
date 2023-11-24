class_name PlayerTouched
extends Ability


signal touched_player_count_changed

@export var touched_state: State

var touched_players: Array[Player] = []


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not multiplayer.is_server():
		return

	if not body is Player:
		return

	touched_players.append(body)
	touched_player_count_changed.emit()
	if player.state_machine.state.name not in _state_names:
		return

	player.state_machine.transition_to.rpc(touched_state.name)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if not multiplayer.is_server():
		return

	if body not in touched_players:
		return

	touched_players.erase(body)
	touched_player_count_changed.emit()


func _on_player_state_machine_transitioned(state_name: String) -> void:
	if state_name not in _state_names:
		return

	if touched_players.size() == 0:
		return

	player.state_machine.transition_to.rpc(touched_state.name)
