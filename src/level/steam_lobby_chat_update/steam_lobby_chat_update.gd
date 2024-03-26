extends Node


func _ready() -> void:
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)


func _on_lobby_chat_update(
		_lobby_id: int,
		changed_id: int,
		_making_change_id: int,
		chat_state: Steam.ChatMemberStateChange
) -> void:
	if chat_state & Steam.CHAT_MEMBER_STATE_CHANGE_ENTERED:
		return

	var steam_multiplayer_peer := multiplayer.multiplayer_peer as SteamMultiplayerPeer
	if not steam_multiplayer_peer:
		return

	for peer_id in multiplayer.get_peers():
		if steam_multiplayer_peer.get_steam64_from_peer_id(peer_id) != changed_id:
			continue

		multiplayer.peer_disconnected.emit(peer_id)
