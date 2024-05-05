extends Node


const AUTOLOAD_PATH = ^"/root/PeerData"
const LOBBY_PROPERTY = &"lobby_id"
const NAME_KEY = "name"
const PLACEHOLDER_LOBBY_ID = -1


func set_lobby_name(value: String) -> void:
	var lobby_id := _get_autoload_lobby_id()
	if Steam.getSteamID() != Steam.getLobbyOwner(lobby_id):
		return

	Steam.setLobbyData(lobby_id, NAME_KEY, value)


func _get_autoload_lobby_id() -> int:
	var autoload := get_node_or_null(AUTOLOAD_PATH)
	if autoload == null:
		return PLACEHOLDER_LOBBY_ID

	var lobby_id: Variant = autoload.get(LOBBY_PROPERTY)
	if not lobby_id is int:
		return PLACEHOLDER_LOBBY_ID

	return lobby_id as int
