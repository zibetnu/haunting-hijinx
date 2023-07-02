extends Node2D


const Battery = preload("res://src/item/battery/battery.tscn")
const Ghost = preload("res://src/player/ghost.tscn")
const Hunter = preload("res://src/player/hunter.tscn")

@export var _battery_spawn_points: Array[NodePath] = []
@export var ghost_spawn_point: Node2D
@export var _hunter_spawn_points: Array[NodePath] = []

var _batteries_spawned := 0
var _ghosts_spawned := 0
var _hunters_spawned := 0

# https://github.com/godotengine/godot/issues/62916#issuecomment-1471750455
@onready var battery_spawn_points := _battery_spawn_points.map(get_node)
@onready var hunter_spawn_points := _hunter_spawn_points.map(get_node)


func _ready():
	# Only the server needs to spawn the players.
	if not multiplayer.is_server():
		return

	multiplayer.peer_connected.connect(add_player)
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

	instance.peer_id = id
	instance.name += str(id)
	instance.died.connect(_on_player_died)
	$SpawnRoot.add_child(instance, true)
	for flashlight in get_tree().get_nodes_in_group("flashlights"):
		if flashlight.is_connected("battery_low", _on_battery_low):
			continue

		flashlight.battery_low.connect(_on_battery_low)


func remove_player(id: int) -> void:
	for player in get_tree().get_nodes_in_group("players"):
		if player.peer_id != id:
			continue

		if player.is_in_group("ghosts"):
			_ghosts_spawned -= 1

		elif player.is_in_group("hunters"):
			_hunters_spawned -= 1

		player.queue_free()


@rpc("call_local", "reliable")
func _end_game(message: String) -> void:
		%EndLabel.text = message
		%EndLabel.visible = true
		if not multiplayer.is_server():
			return

		await get_tree().create_timer(3).timeout
		SceneChanger.change_scene_to_packed(SceneChanger.lobby)


func _on_battery_low() -> void:
	if not multiplayer.is_server():
		return

	var batteries_needed = get_tree().get_nodes_in_group("flashlights").reduce(
			func(accum, flashlight): return accum + int(flashlight.is_battery_low), 0
	)

	if _batteries_spawned >= batteries_needed:
		return

	# TODO: ensure that batteries don't spawn on a player or on each other.
	var instance = Battery.instantiate()
	instance.position = battery_spawn_points.pick_random().position
	instance.tree_exited.connect(_on_battery_tree_exited)
	$SpawnRoot.add_child(instance, true)
	_batteries_spawned += 1


func _on_battery_tree_exited() -> void:
	_batteries_spawned -= 1


func _on_player_died() -> void:
	if not multiplayer.is_server():
		return

	var player_is_dead := func(player: Player): return player.health == 0
	if get_tree().get_nodes_in_group("ghosts").all(player_is_dead):
		_end_game.rpc("Hunters win!")

	elif get_tree().get_nodes_in_group("hunters").all(player_is_dead):
		_end_game.rpc("Ghost wins!")
