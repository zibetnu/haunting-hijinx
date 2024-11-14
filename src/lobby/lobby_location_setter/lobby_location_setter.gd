extends Node

const AUTOLOAD_PATH := ^"/root/PeerData"
const LOBBY_PROPERTY := &"lobby_id"
const LOCATION_KEY := "location"
const PLACEHOLDER_LOCATION := [0]
const PLACEHOLDER_LOBBY_ID := -1


func set_lobby_location() -> void:
	var lobby_id := _get_autoload_lobby_id()
	if Steam.getSteamID() != Steam.getLobbyOwner(lobby_id):
		return

	var ping_dict: Dictionary = Steam.getLocalPingLocation()
	Steam.setLobbyData(
			lobby_id,
			LOCATION_KEY,
			Steam.convertPingLocationToString(
					ping_dict.get(LOCATION_KEY, PLACEHOLDER_LOCATION)
			)
	)


func _get_autoload_lobby_id() -> int:
	var autoload := get_node_or_null(AUTOLOAD_PATH)
	if not autoload:
		return PLACEHOLDER_LOBBY_ID

	var lobby_id = autoload.get(LOBBY_PROPERTY)
	if not lobby_id is int:
		return PLACEHOLDER_LOBBY_ID

	return int(lobby_id)
