extends Node

signal lobby_name_on_ready(lobby_name: String)

const NAME_KEY = "name"


func _ready() -> void:
	lobby_name_on_ready.emit(get_lobby_name())


func get_lobby_name() -> String:
	return Steam.getLobbyData(PeerData.lobby_id, NAME_KEY)


func set_lobby_name(value: String) -> void:
	if Steam.getSteamID() != Steam.getLobbyOwner(PeerData.lobby_id):
		return

	Steam.setLobbyData(PeerData.lobby_id, NAME_KEY, value)
