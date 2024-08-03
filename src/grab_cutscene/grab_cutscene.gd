extends Node
## This is jank code that's mostly copied over from the older version of the
## game, but it's fine for now since it'll be completely remade later.


signal cutscene_ended

var _cutscene_name := "grab"
var _tree_paused := false:  # Used to sync pause state across all peers.
	set(value):
		get_tree().set_pause(value)
		_tree_paused = get_tree().paused


func start_cutscene() -> void:
	if multiplayer.is_server():
		CutsceneManager.play_cutscene.rpc(_cutscene_name, 2)


func _on_cutscene_ended(cutscene_name: String) -> void:
	if cutscene_name != _cutscene_name:
		return

	_focus_cameras_local()
	if not multiplayer.is_server():
		return

	_tree_paused = false
	cutscene_ended.emit()


func _on_cutscene_started(cutscene_name: String) -> void:
	if cutscene_name != _cutscene_name:
		return

	_focus_cameras_ghost()
	$GrabSound.play()
	if not multiplayer.is_server():
		return

	_sync_ghost.rpc(owner.position)
	_tree_paused = true


func _focus_cameras_ghost() -> void:
	get_tree().get_first_node_in_group("ghosts").get_node("Camera2D").enabled = true
	for hunter in get_tree().get_nodes_in_group("hunters"):
		hunter.get_node("Camera2D").enabled = false


func _focus_cameras_local() -> void:
	for player in get_tree().get_nodes_in_group("players"):
		var is_local = player.get_node("PeerID").id == multiplayer.get_unique_id()
		player.get_node("Camera2D").enabled = is_local


@rpc("reliable")
func _sync_ghost(value: Vector2) -> void:
	owner.position = value
	$"../GhostVisible".set_value_true()
