extends Node


signal connection_closed
signal create_lobby_failed
signal join_lobby_failed
signal lobby_created
signal lobby_joined

const AUTOLOAD_PATH = ^"/root/PeerData"
const LOBBY_ID_PROPERTY = &"lobby_id"
const PLACEHOLDER_LOBBY_ID = -1

const MAX_MEMBERS = 8


func _ready() -> void:
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)


func close_connection() -> void:
	var lobby_id := _get_autoload_lobby_id()
	if lobby_id != PLACEHOLDER_LOBBY_ID:
		Steam.leaveLobby(lobby_id)
		_set_autoload_property(LOBBY_ID_PROPERTY, PLACEHOLDER_LOBBY_ID)

	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	connection_closed.emit()


func create_lobby() -> void:
	if not Steam.isSteamRunning():
		return

	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, MAX_MEMBERS)


func join_lobby(lobby_id: int) -> void:
	if not Steam.isSteamRunning():
		return

	Steam.joinLobby(lobby_id)


func _on_lobby_created(result: Steam.Result, lobby_id: int) -> void:
	if result != Steam.RESULT_OK:
		create_lobby_failed.emit()
		return

	var peer := SteamMultiplayerPeer.new()
	peer.create_host(0, [])
	multiplayer.multiplayer_peer = peer
	_set_autoload_property(LOBBY_ID_PROPERTY, lobby_id)
	lobby_created.emit()


func _on_lobby_joined(
			lobby_id: int,
			_permissions: int,
			_locked: bool,
			response: Steam.ChatRoomEnterResponse
	) -> void:
	if response != Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		join_lobby_failed.emit()
		return

	# Don't set peer again if it was already set in _on_lobby_created.
	var lobby_owner_steam_id := Steam.getLobbyOwner(lobby_id)
	if Steam.getSteamID() == lobby_owner_steam_id:
		return

	var peer := SteamMultiplayerPeer.new()
	peer.create_client(lobby_owner_steam_id, 0, [])
	multiplayer.multiplayer_peer = peer
	_set_autoload_property(LOBBY_ID_PROPERTY, lobby_id)
	lobby_joined.emit()


# TODO: move autoload get/set functions to dedicated script.
func _get_autoload_lobby_id() -> int:
	var autoload := get_node_or_null(AUTOLOAD_PATH)
	if autoload == null:
		return PLACEHOLDER_LOBBY_ID

	var lobby_id: Variant = autoload.get(LOBBY_ID_PROPERTY)
	if not lobby_id is int:
		return PLACEHOLDER_LOBBY_ID

	return lobby_id as int


func _set_autoload_property(property: StringName, value: Variant) -> void:
	var autoload := get_node_or_null(AUTOLOAD_PATH)
	if autoload:
		autoload.set(property, value)
