extends Node2D

@export var ghost: PackedScene
@export var ghost_spawn_point: Node2D
@export var hunter: PackedScene
@export var hunter_spawn_points: Array[Node2D] = []
@export var spectator_menu: PackedScene

var _ghosts_spawned := 0
var _hunters_spawned := 0

@onready var end_label: Label = %EndLabel
@onready var ghost_timer_sprite: Node2D = %GhostTimerSprite
@onready var hunter_timer_sprite: Node2D = %HunterTimerSprite
@onready var limit_bottom_right: Marker2D = $CameraLimits/BottomRight
@onready var limit_top_left: Marker2D = $CameraLimits/TopLeft
@onready var match_timer: Timer = %MatchTimer
@onready var spectator_timer_sprite: Node2D = %SpectatorTimerSprite


func _ready() -> void:
	show_matching_timer_sprite()

	if not multiplayer.is_server():
		return

	PeerData.match_in_progress = true
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(remove_player)

	for peer_id: int in PeerData.participants:
		add_player(peer_id)


func _exit_tree() -> void:
	PeerData.match_in_progress = false


func add_player(id: int) -> void:
	var instance: Node2D = null
	if id == PeerData.ghost_peer:
		instance = ghost.instantiate()
		instance.position = ghost_spawn_point.position
		_ghosts_spawned += 1

	else:
		instance = hunter.instantiate()
		instance.position = hunter_spawn_points[
				_hunters_spawned % hunter_spawn_points.size()
		].position
		_hunters_spawned += 1

	var camera: Camera2D = instance.get_node_or_null(^"%Camera2D")
	if camera != null:
		_set_camera_limits(camera)

	instance.name += str(id)
	$SpawnRoot.add_child(instance, true)
	var peer_id: PeerID = instance.get_node_or_null(^"%PeerID")
	if peer_id != null:
		peer_id.id = id

	var name_label: Label = instance.get_node_or_null(^"%NameLabel")
	if name_label != null:
		name_label.text = PeerData.peer_names[id]

	get_tree().call_group("ghost_peer_ids", "set_id", PeerData.ghost_peer)


func remove_player(id: int) -> void:
	for player in get_tree().get_nodes_in_group("players"):
		var peer_id: PeerID = player.get_node_or_null(^"%PeerID")
		if peer_id == null:
			continue

		if peer_id.id != id:
			continue

		if player.is_in_group("ghosts"):
			_ghosts_spawned -= 1

		elif player.is_in_group("hunters"):
			_hunters_spawned -= 1

		player.queue_free()
		_on_player_death_state_changed()


## Shows timer sprite matching the local peer's type.
func show_matching_timer_sprite() -> void:
	var local_peer_type: int = PeerData.get_peer_type(
			multiplayer.get_unique_id()
	)
	var peer_type: Dictionary = PeerData.PeerType
	hunter_timer_sprite.visible = local_peer_type == peer_type.HUNTER
	ghost_timer_sprite.visible = local_peer_type == peer_type.GHOST
	spectator_timer_sprite.visible = local_peer_type == peer_type.SPECTATOR


func _end_match(message: String) -> void:
	if not multiplayer.is_server():
		return

	end_label.text = message
	end_label.visible = true

	# Force level to stay paused even if scene tree is not paused.
	set_process_mode.call_deferred(Node.PROCESS_MODE_DISABLED)

	await get_tree().create_timer(3).timeout
	SceneChanger.change_scene_to_packed(SceneChanger.lobby)


func _on_counting_spawner_all_scenes_spawned() -> void:
	if multiplayer.get_unique_id() not in PeerData.spectators:
		return

	if $CanvasLayer.get_children().any(
			func(node: Node) -> bool: return node.name == "SpectatorMenu"
	):
		return

	$CanvasLayer.add_child(spectator_menu.instantiate())


func _on_group_bool_ready(group_bool: GroupBool) -> void:
	group_bool.is_true_set.connect(_on_player_death_state_changed)
	group_bool.tree_exiting.connect(_on_player_death_state_changed)


func _on_match_timer_timeout() -> void:
	_end_match("Draw!")


func _on_player_death_state_changed() -> void:
	if not multiplayer.is_server():
		return

	var is_dead := func(node: Node) -> bool:
		return (
				node.get("is_true")
				or node.owner == null
				or node.owner.is_queued_for_deletion()
		)

	if get_tree().get_nodes_in_group("ghost_is_deads").all(is_dead):
		_end_match("Hunters win!")

	elif get_tree().get_nodes_in_group("hunter_is_deads").all(is_dead):
		_end_match("Ghost wins!")


func _on_peer_connected(id: int) -> void:
	if not is_inside_tree():
		return

	_sync_timer.rpc_id(id, match_timer.time_left)


func _set_camera_limits(camera: Camera2D) -> void:
	camera.limit_left = roundi(limit_top_left.position.x)
	camera.limit_top = roundi(limit_top_left.position.y)
	camera.limit_right = roundi(limit_bottom_right.position.x)
	camera.limit_bottom = roundi(limit_bottom_right.position.y)


@rpc("reliable")
func _sync_timer(time_left: float) -> void:
	match_timer.start(time_left)
