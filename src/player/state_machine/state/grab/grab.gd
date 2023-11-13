extends State


@export var exit_state: State

var _cutscene_name := "grab"


func enter(_message := {}) -> void:
	if multiplayer.is_server():
		CutsceneManager.play_cutscene.rpc(_cutscene_name, 2)


func _on_cutscene_ended(cutscene_name: String) -> void:
	if cutscene_name != _cutscene_name:
		return

	if not multiplayer.is_server():
		return

	PauseManager.set_pause.rpc(false)
	state_machine.transition_to.rpc(exit_state.name)


func _on_cutscene_started(cutscene_name: String) -> void:
	if cutscene_name != _cutscene_name:
		return

	for _player in get_tree().get_nodes_in_group("players"):
		_player.get_node("Camera2D").enabled = (
				_player.peer_id == player.peer_id
		)

	if not multiplayer.is_server():
		return

	PauseManager.set_pause.rpc(true)
