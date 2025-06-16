# TODO: refactor separate lobby setter scenes to be one scene.
extends Node

signal lobby_type_on_ready(lobby_type: Steam.LobbyType)

const TYPE_KEY = "type"
const TYPES_TO_STRINGS = {
	Steam.LOBBY_TYPE_PRIVATE: "Private",
	Steam.LOBBY_TYPE_FRIENDS_ONLY: "Friends Only",
	Steam.LOBBY_TYPE_PUBLIC: "Public",
	Steam.LOBBY_TYPE_INVISIBLE: "Invisible",
	Steam.LOBBY_TYPE_PRIVATE_UNIQUE: "Private Unique",
}

const DEFAULT_LOBBY_TYPE = Steam.LOBBY_TYPE_PRIVATE

@onready var lobby_id: int = PeerData.lobby_id


func _ready() -> void:
	lobby_type_on_ready.emit(get_lobby_type())


func get_lobby_type_string() -> String:
	return Steam.getLobbyData(lobby_id, TYPE_KEY)


func get_lobby_type() -> Steam.LobbyType:
	var lobby_type_string := get_lobby_type_string()
	var type_strings: Array[String] = []
	type_strings.assign(TYPES_TO_STRINGS.values())

	if not lobby_type_string in type_strings:
		set_lobby_type(DEFAULT_LOBBY_TYPE)
		return DEFAULT_LOBBY_TYPE

	return TYPES_TO_STRINGS.keys()[type_strings.find(lobby_type_string)]


func set_lobby_type(value: Steam.LobbyType) -> void:
	if Steam.getSteamID() != Steam.getLobbyOwner(lobby_id):
		return

	if value not in TYPES_TO_STRINGS.keys():
		return

	Steam.setLobbyType(lobby_id, value)
	Steam.setLobbyData(
			lobby_id,
			TYPE_KEY,
			TYPES_TO_STRINGS.get(value) as String
	)
