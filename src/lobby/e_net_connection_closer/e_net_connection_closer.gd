extends Node


signal connection_closed


func close_connection() -> void:
	for peer in multiplayer.get_peers():
		multiplayer.multiplayer_peer.disconnect_peer(peer)

	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	connection_closed.emit()
