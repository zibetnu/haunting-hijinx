extends Node


const MIN_PARTICIPANTS = 1
const MAX_PARTICIPANTS = 5

signal ghost_peer_changed(id: int)
signal peer_name_changed(id: int)
signal peer_participation_changed(id: int)

@export var ghost_peer := 1:
	set(value):
		ghost_peer = value
		ghost_peer_changed.emit(value)

@export var participants: Array[int] = []
@export var peer_names := {}
@export var spectators: Array[int] = []


func _ready() -> void:
	ConnectionManager.connection_closed.connect(erase_peer_data)
	ConnectionManager.server_created.connect(_on_server_created)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.server_disconnected.connect(erase_peer_data)


func erase_peer_data() -> void:
	participants = []
	ghost_peer = 1
	peer_names = {}
	spectators = []


@rpc("call_local", "reliable")
func set_peer_name(id: int, peer_name: String) -> void:
	if peer_names.get(id, null) == peer_name:
		return

	peer_names[id] = peer_name
	peer_name_changed.emit(id)


func toggle_participation(id: int) -> void:
	if id in participants:
		participants.erase(id)
		spectators.append(id)

	elif id in spectators and participants.size() < MAX_PARTICIPANTS:
		spectators.erase(id)
		participants.append(id)

	else:
		return

	peer_participation_changed.emit(id)


func _on_peer_disconnected(id: int) -> void:
	if not multiplayer.is_server():
		return

	participants.erase(id)
	peer_names.erase(id)
	spectators.erase(id)


func _on_peer_connected(id: int) -> void:
	if not multiplayer.is_server():
		return

	var peer_name := "Player %s" % str(id)
	if peer_names.has(id):
		peer_name = peer_names[id]

	set_peer_name.rpc(id, peer_name)

	if participants.size() < MAX_PARTICIPANTS:
		participants.append(id)

	else:
		spectators.append(id)

	peer_participation_changed.emit(id)


func _on_server_created() -> void:
	if not OS.has_feature("dedicated_server"):
		_on_peer_connected(1)
