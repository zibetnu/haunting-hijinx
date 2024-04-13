extends Node


const AUTOLOAD_PATH := ^"/root/PeerData"
const LOBBY_PROPERTY := &"lobby_id"
const LOCATION_KEY := "location"
const PLACEHOLDER_LOCATION := [0]
const PLACEHOLDER_LOBBY_ID := -1


func _ready() -> void:
	Steam.relay_network_status.connect(_on_relay_network_status)
	match Steam.getRelayNetworkStatus():
		Steam.NETWORKING_AVAILABILITY_NEVER_TRIED:
			Steam.initRelayNetworkAccess()

		Steam.NETWORKING_AVAILABILITY_CURRENT:
			set_lobby_location()


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


func _on_relay_network_status(
		available: int,
		_ping_measurement: int,
		_available_config: int,
		_available_relay: int,
		_debug_message: String
) -> void:
	if available == Steam.NETWORKING_AVAILABILITY_CURRENT:
		set_lobby_location()
