extends Node2D


const Battery = preload("res://src/item/battery/battery.tscn")
const Ghost = preload("res://src/player/ghost.tscn")
const Hunter = preload("res://src/player/hunter.tscn")
const SpectatorMenu = preload("res://src/level/spectator_menu/spectator_menu.tscn")
const MAX_BATTERY_SPAWN_ATTEMPTS = 100

@export var battery_area_top_left: Node2D
@export var battery_area_bottom_right: Node2D
@export var ghost_spawn_point: Node2D
@export var hunter_spawn_points: Array[Node2D] = []

var _batteries_spawned := 0
var _ghosts_spawned := 0
var _hunters_spawned := 0


func _ready():
	if multiplayer.get_unique_id() in PeerData.spectators:
		$CanvasLayer.add_child(SpectatorMenu.instantiate())

	# Only the server needs to spawn the players.
	if not multiplayer.is_server():
		return

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
		SceneChanger.change_scene_to_packed(SceneChanger.lobby)


func _get_random_battery_position() -> Vector2:
	return Vector2(
			randf_range(battery_area_top_left.position.x, battery_area_bottom_right.position.x),
			randf_range(battery_area_top_left.position.y, battery_area_bottom_right.position.y)
	)


func _is_position_clear(check_position: Vector2) -> bool:
	var shape_rid := PhysicsServer2D.circle_shape_create()
	var radius := 8
	PhysicsServer2D.shape_set_data(shape_rid, radius)

	var parameters := PhysicsShapeQueryParameters2D.new()
	parameters.collide_with_areas = true
	parameters.exclude += get_tree().get_nodes_in_group("aura_areas").map(
			func(aura_area): return aura_area.get_rid()
	)
	parameters.shape_rid = shape_rid
	parameters.transform = Transform2D(0, check_position)

	var intersections := get_world_2d().direct_space_state.intersect_shape(parameters)
	PhysicsServer2D.free_rid(shape_rid)
	return intersections.size() == 0


func _on_battery_spawn_timer_timeout() -> void:
	if not multiplayer.is_server():
		return

	var batteries_needed = 0
	for flashlight in get_tree().get_nodes_in_group("flashlights"):
		if not flashlight.is_battery_low:
			continue

		if flashlight.player.health == 0:
			continue

		batteries_needed += 1

	if _batteries_spawned >= batteries_needed:
		return

	var instance = Battery.instantiate()
	var instance_position := _get_random_battery_position()
	var i := 0
	while i < MAX_BATTERY_SPAWN_ATTEMPTS and not _is_position_clear(instance_position):
		instance_position = _get_random_battery_position()
		i += 1

	if not (i < MAX_BATTERY_SPAWN_ATTEMPTS):
		push_error("Could not find valid battery spawn point.")
		instance.queue_free()
		return

	instance.position = instance_position
	instance.tree_exited.connect(_on_battery_tree_exited)
	$SpawnRoot.add_child(instance, true)
	_batteries_spawned += 1


func _on_battery_tree_exited() -> void:
	_batteries_spawned -= 1


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
