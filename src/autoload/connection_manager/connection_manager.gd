extends Node


signal server_created


func _ready() -> void:
	# Disable server relay to ensure that data is only shared between clients when necessary.
	multiplayer.server_relay = false
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func close_connection() -> void:
	for peer in multiplayer.get_peers():
		multiplayer.multiplayer_peer.disconnect_peer(peer)

	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()


func create_client(address: String, port: int) -> bool:
	var peer := ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		_notify_user("Failed to create client")
		return false

	multiplayer.multiplayer_peer = peer
	return true


func create_server(port: int) -> void:
	var peer := ENetMultiplayerPeer.new()
	peer.create_server(port)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		_notify_user("Failed to create server")
		return

	multiplayer.multiplayer_peer = peer
	server_created.emit()


func _notify_user(message: String) -> void:
	$NotifyDialog.dialog_text = message
	$NotifyDialog.popup_centered()
	print(message)


func _on_server_disconnected() -> void:
	close_connection()
	_notify_user("Disconnected from server")
