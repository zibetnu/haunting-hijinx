extends Node2D


const Ghost = preload("res://src/player/ghost.tscn")
const Hunter = preload("res://src/player/hunter.tscn")
const SpectatorMenu = preload("res://src/level/spectator_menu/spectator_menu.tscn")

@export var ghost_spawn_point: Node2D
@export var hunter_spawn_points: Array[Node2D] = []

var _ghosts_spawned := 0
var _hunters_spawned := 0


func _ready():
	# Only the server needs to spawn the players.
	if not multiplayer.is_server():
		return

	PeerData.match_in_progress = true
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(remove_player)

	# Spawn active players.
	for peer_id in PeerData.participants:
		add_player(peer_id)


func add_player(id: int) -> void:
	if _ghosts_spawned + _hunters_spawned >= PeerData.MAX_PARTICIPANTS:
		return

	var instance: Player = null
	if id == PeerData.ghost_peer:
		instance = Ghost.instantiate()
		instance.position = ghost_spawn_point.position
		_ghosts_spawned += 1

	else:
		instance = Hunter.instantiate()
		instance.position = hunter_spawn_points[
				_hunters_spawned % hunter_spawn_points.size()
		].position
		_hunters_spawned += 1

	instance.camera_limits = $LevelLimit.position
	instance.peer_id = id
	instance.name += str(id)
	instance.died.connect(_on_player_died)
	$SpawnRoot.add_child(instance, true)


func allow_set_pause() -> bool:
	return not %EndLabel.visible or not get_tree().paused


func remove_player(id: int) -> void:
	for player in get_tree().get_nodes_in_group("players"):
		if player.peer_id != id:
			continue

		if player.is_in_group("ghosts"):
			_ghosts_spawned -= 1

		elif player.is_in_group("hunters"):
			_hunters_spawned -= 1

		player.queue_free()
		_on_player_died()


func _end_match(message: String) -> void:
		%EndLabel.text = message
		%EndLabel.visible = true
		if not multiplayer.is_server():
			return

		PauseManager.set_pause.rpc(true)
		await get_tree().create_timer(3).timeout
		PeerData.match_in_progress = false
		SceneChanger.change_scene_to_packed(SceneChanger.lobby)


func _on_counting_spawner_all_scenes_spawned() -> void:
	if multiplayer.get_unique_id() not in PeerData.spectators:
		return

	if $CanvasLayer.get_children().any(
			func(node): return node.name == "SpectatorMenu"
	):
		return

	$CanvasLayer.add_child(SpectatorMenu.instantiate())


func _on_match_timer_timeout() -> void:
	_end_match("Draw!")


func _on_player_died() -> void:
	var player_is_dead := func(player: Player):
			return player.health == 0 or player.is_queued_for_deletion()

	if get_tree().get_nodes_in_group("ghosts").all(player_is_dead):
		_end_match("Hunters win!")

	elif get_tree().get_nodes_in_group("hunters").all(player_is_dead):
		_end_match("Ghost wins!")


func _on_peer_connected(id: int) -> void:
	_sync_timer.rpc_id(id, $MatchTimer.time_left)


@rpc
func _sync_timer(time_left: float) -> void:
	$MatchTimer.start(time_left)
