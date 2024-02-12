extends Node2D


const Ghost = preload("res://src/ghost/ghost.tscn")
const Hunter = preload("res://src/hunter/hunter.tscn")
const SpectatorMenu = preload("res://src/level/spectator_menu/spectator_menu.tscn")

@export var ghost_spawn_point: Node2D
@export var hunter_spawn_points: Array[Node2D] = []

var _ghosts_spawned := 0
var _hunters_spawned := 0


func _ready():
	get_tree().root.size_changed.connect(center_play_area)
	center_play_area()

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

	var instance: Node2D = null
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

	_set_camera_limits(instance.get_node("Camera2D"))
	instance.name += str(id)
	$SpawnRoot.add_child(instance, true)
	instance.get_node("PeerID").id = id
	get_tree().call_group("peer_visibility_filters", "set_secondary_peer_id", PeerData.ghost_peer)


func allow_set_pause() -> bool:
	return not %EndLabel.visible or not get_tree().paused


func center_play_area() -> void:
	var visible_rect_size := get_tree().root.get_visible_rect().size
	var bottom_right_camera_limit: Vector2 = $CameraLimits/BottomRight.position
	if visible_rect_size.x > bottom_right_camera_limit.x:
		position.x = (bottom_right_camera_limit.x - visible_rect_size.x) / 2

	else:
		position.x = 0

	if visible_rect_size.y > bottom_right_camera_limit.y:
		position.y = (visible_rect_size.y - bottom_right_camera_limit.y) / 2

	else:
		position.y = 0

	# Tile map light occluders will not match the new position of the tile maps
	# unless visibility is toggled. This may be a bug in Godot.
	visible = false
	visible = true


func remove_player(id: int) -> void:
	for player in get_tree().get_nodes_in_group("players"):
		if player.get_node("PeerID").id != id:
			continue

		if player.is_in_group("ghosts"):
			_ghosts_spawned -= 1

		elif player.is_in_group("hunters"):
			_hunters_spawned -= 1

		player.queue_free()
		_on_player_death_state_changed()


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


func _on_group_bool_ready(group_bool: Node) -> void:
	if group_bool.has_signal("is_true_set"):
		group_bool.is_true_set.connect(_on_player_death_state_changed)

	group_bool.tree_exiting.connect(_on_player_death_state_changed)


func _on_match_timer_timeout() -> void:
	_end_match("Draw!")


func _on_player_death_state_changed() -> void:
	if not multiplayer.is_server():
		return

	var is_dead := func(node: Node):
			return node.get("is_true") or node.owner.is_queued_for_deletion()

	if get_tree().get_nodes_in_group("ghost_is_deads").all(is_dead):
		_end_match("Hunters win!")

	elif get_tree().get_nodes_in_group("hunter_is_deads").all(is_dead):
		_end_match("Ghost wins!")


func _on_peer_connected(id: int) -> void:
	_sync_timer.rpc_id(id, $MatchTimer.time_left)


func _set_camera_limits(camera: Camera2D) -> void:
	camera.limit_left = $CameraLimits/TopLeft.position.x
	camera.limit_top = $CameraLimits/TopLeft.position.y
	camera.limit_right = $CameraLimits/BottomRight.position.x
	camera.limit_bottom = $CameraLimits/BottomRight.position.y


@rpc
func _sync_timer(time_left: float) -> void:
	$MatchTimer.start(time_left)
