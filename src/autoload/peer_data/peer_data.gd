extends Node

signal peer_connected(id: int)
signal ghost_peer_changed(id: int)
signal peer_name_changed(id: int)
signal peer_participation_changed(id: int)
signal selected_level_changed(value: Level)

enum PeerType {
	HUNTER = 0,
	GHOST = 1,
	SPECTATOR = 2,
}

const MAX_PARTICIPANTS = 5

@export var ghost_peer := 1:
	set(value):
		ghost_peer = value
		ghost_peer_changed.emit(value)

@export var participants: Array[int] = []
@export var peer_names := {}
@export var spectators := []

@export_group("Levels", "levels")
@export var levels: Array[Level]
@export var levels_selected_index: int:
	set = set_levels_selected_index

var peer_ghost_hats: Dictionary[int, int]
var peer_hunter_hats: Dictionary[int, int]
var hunter_palette_indexes: Dictionary[int, int]
var hunter_palette_preferences: Dictionary[int, Array]
var lobby_id := -1
var match_in_progress := false


func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.peer_disconnected.connect(erase_data_for_peer)
	multiplayer.server_disconnected.connect(erase_data)


# TODO: lots of cleanup.
func assign_hunter_palette_indexes() -> void:
	hunter_palette_indexes.clear()

	var hunters: Array[int]
	hunters.assign(participants.filter(_is_hunter))
	hunters.resize(5)

	var best_score: int = 2^63
	var best_permutation: Array[int]
	for permutation in get_permutations(hunters):
		var score: int = get_score(permutation)
		if score >= best_score:
			continue

		best_score = score
		best_permutation.assign(permutation)
		if best_score == 0:
			break

	for peer_id in best_permutation:
		hunter_palette_indexes[peer_id] = best_permutation.find(peer_id)



# https://www.quickperm.org
func get_permutations(array: Array) -> Array[Array]:
	var permutations: Array[Array] = [array.duplicate()]

	var n: int = array.size()
	var p: Array[int]
	for i in range(n + 1):
		p.append(i)

	var i: int = 1
	while i < n:
		p[i] -= 1
		var j: int = p[i] if i % 2 != 0 else 0

		var temp: int = array[j]
		array[j] = array[i]
		array[i] = temp

		permutations.append(array.duplicate())
		i = 1
		while p[i] == 0:
			p[i] = i
			i += 1

	return permutations


func get_score(array: Array) -> int:
	var score: int = 0
	for i in array.size():
		if array[i] not in hunter_palette_preferences:
			continue

		var preference_index: int = hunter_palette_preferences[array[i]].find(i)
		score += preference_index

	return score


func get_selected_level() -> Level:
	return levels[levels_selected_index]


func set_levels_selected_index(value: int) -> void:
	levels_selected_index = posmod(value, levels.size())
	selected_level_changed.emit(get_selected_level())


func erase_data() -> void:
	ghost_peer = 1
	match_in_progress = false
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


func get_peer_type(id: int) -> PeerType:
	if id in spectators:
		return PeerType.SPECTATOR

	if id == ghost_peer:
		return PeerType.GHOST

	return PeerType.HUNTER


@rpc("call_local", "reliable")
func set_peer_name(id: int, peer_name: String) -> void:
	if peer_names.get(id, null) == peer_name:
		return

	peer_names[id] = peer_name
	peer_name_changed.emit(id)


func set_peer_type(id: int, type: PeerType) -> void:
	match type:
		PeerType.HUNTER:
			if id in spectators:
				toggle_participation(id)

			if id == ghost_peer:
				ghost_peer = -1

		PeerType.GHOST:
			if id in spectators:
				toggle_participation(id)

			ghost_peer = id

		PeerType.SPECTATOR:
			if id in participants:
				toggle_participation(id)


func toggle_participation(id: int) -> void:
	if id in participants:
		participants.erase(id)
		spectators.append(id)

	elif id in spectators:
		spectators.erase(id)
		participants.append(id)

	else:
		return

	peer_participation_changed.emit(id)


@rpc("any_peer", "call_remote", "reliable")
func request_init(customization: Dictionary[String, Variant] = {}) -> void:
	init_peer(multiplayer.get_remote_sender_id(), customization)


func init_peer(id: int, customization: Dictionary[String, Variant] = {}) -> void:
	if not multiplayer.is_server():
		return

	peer_ghost_hats[id] = customization.get("ghost_hat", 0)
	peer_hunter_hats[id] = customization.get("hunter_hat", 0)
	hunter_palette_preferences[id] = customization.get("hunter_colors", [])

	var peer_name: String = customization.get("default_name", "")
	if peer_name.is_empty():
		peer_name = "Player %s" % str(id)

	elif peer_names.has(id):
		peer_name = peer_names[id]

	set_peer_name.rpc(id, peer_name)
	if participants.size() >= MAX_PARTICIPANTS or match_in_progress:
		spectators.append(id)

	else:
		participants.append(id)

	# If there are now too many hunters, make this new peer the ghost.
	if participants.filter(_is_hunter).size() >= MAX_PARTICIPANTS - 1:
		ghost_peer = id

	peer_connected.emit(id)


func _is_hunter(id: int) -> bool:
	return get_peer_type(id) == PeerType.HUNTER


func _on_connected_to_server() -> void:
	request_init.rpc(GameConfig.customization.get_as_dict())
