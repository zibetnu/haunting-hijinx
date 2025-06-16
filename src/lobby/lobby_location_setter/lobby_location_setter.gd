extends Node

const LOCATION_KEY := "location"
const PLACEHOLDER_LOCATION := [0]


func set_lobby_location() -> void:
	if Steam.getSteamID() != Steam.getLobbyOwner(PeerData.lobby_id):
		return

	var ping_dict: Dictionary = Steam.getLocalPingLocation()
	Steam.setLobbyData(
			PeerData.lobby_id,
			LOCATION_KEY,
			Steam.convertPingLocationToString(
					ping_dict.get(LOCATION_KEY, PLACEHOLDER_LOCATION) as Array
			)
	)
