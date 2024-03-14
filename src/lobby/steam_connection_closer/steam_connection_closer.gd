extends Node


signal connection_closed

const AUTOLOAD_LOBBY_PROPERTY := &"lobby_id"
const AUTOLOAD_PATH := ^"/root/PeerData"
const DEFAULT_LOBBY_ID := -1


func close_connection() -> void:
	var lobby_id = _get_autoload_lobby_id()
	if lobby_id != null and lobby_id != DEFAULT_LOBBY_ID:
		Steam.leaveLobby(lobby_id)
		_set_autoload_lobby_id(DEFAULT_LOBBY_ID)

	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	connection_closed.emit()


func _get_autoload_lobby_id() -> Variant:
	var autoload := get_node_or_null(AUTOLOAD_PATH)
	if autoload:
		return autoload.get(AUTOLOAD_LOBBY_PROPERTY)

	return null


func _set_autoload_lobby_id(lobby_id: int) -> void:
	var autoload := get_node_or_null(AUTOLOAD_PATH)
	if autoload:
		autoload.set(AUTOLOAD_LOBBY_PROPERTY, lobby_id)
