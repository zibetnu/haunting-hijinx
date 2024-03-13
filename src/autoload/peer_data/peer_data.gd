extends Node


const MAX_PARTICIPANTS = 5

signal ghost_peer_changed(id: int)
signal peer_name_changed(id: int)
signal peer_participation_changed(id: int)

@export var ghost_peer := 1:
	set(value):
		ghost_peer = value
		ghost_peer_changed.emit(value)

# participants and spectators are not typed as Array[int] due to
# a bug that prevents a MultiplayerSynchronizer from syncing them.
# See https://github.com/godotengine/godot/issues/74391.
@export var participants := []
@export var peer_names := {}
@export var spectators := []

var lobby_id := -1
var match_in_progress := false


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(erase_data_for_peer)
	multiplayer.server_disconnected.connect(erase_data)


func erase_data() -> void:
	ghost_peer = 1
	participants = []
	peer_names = {}
	spectators = []


func erase_data_for_peer(id: int) -> void:
	if ghost_peer == id:
		ghost_peer = 1

	participants.erase(id)
	peer_names.erase(id)
	spectators.erase(id)
	peer_participation_changed.emit(id)


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


func _on_peer_connected(id: int) -> void:
	if id == 1:  # A new server is starting, so erase old data.
		erase_data()

	if not multiplayer.is_server():
		return

	var peer_name := "Player %s" % str(id)
	if peer_names.has(id):
		peer_name = peer_names[id]

	set_peer_name.rpc(id, peer_name)

	if participants.size() < MAX_PARTICIPANTS and not match_in_progress:
		participants.append(id)

	else:
		spectators.append(id)

	peer_participation_changed.emit(id)
