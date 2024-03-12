extends Node


signal create_lobby_failed
signal join_lobby_failed
signal lobby_created
signal lobby_joined

const MAX_MEMBERS := 8

var join_lobby_id := -1


func _ready() -> void:
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.steamInit()


func create_lobby() -> void:
	if not Steam.isSteamRunning():
		return

	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, MAX_MEMBERS)


func join_lobby() -> void:
	if not Steam.isSteamRunning():
		return

	Steam.joinLobby(join_lobby_id)


func set_join_lobby_id_from_string(value: String) -> void:
	join_lobby_id = int(value)


func _on_lobby_created(result: Steam.Result, lobby_id: int) -> void:
	if result != Steam.RESULT_OK:
		create_lobby_failed.emit()
		return

	var peer := SteamMultiplayerPeer.new()
	peer.create_host(0, [])
	multiplayer.multiplayer_peer = peer
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
	lobby_joined.emit()
