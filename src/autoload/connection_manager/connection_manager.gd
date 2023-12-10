extends Node


signal client_created
signal connection_closed
signal server_created


func _ready() -> void:
	# Disable server relay to ensure that data is only shared between clients when necessary.
	multiplayer.server_relay = false
	multiplayer.connected_to_server.connect($ConnectingDialog.hide)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func close_connection() -> void:
	for peer in multiplayer.get_peers():
		multiplayer.multiplayer_peer.disconnect_peer(peer)

	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	connection_closed.emit()


func create_client(address: String, port: int) -> void:
	var peer := ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		_notify_user("Failed to create client")
		return

	multiplayer.multiplayer_peer = peer
	client_created.emit()
	$ConnectingDialog.popup_centered()


func create_server(port: int) -> void:
	var peer := ENetMultiplayerPeer.new()
	peer.create_server(port)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		_notify_user("Failed to create server")
		return

	multiplayer.multiplayer_peer = peer
	server_created.emit()


func _notify_user(message: String) -> void:
	$ConnectingDialog.hide()
	$NotifyDialog.dialog_text = message
	$NotifyDialog.popup_centered()
	print(message)


func _on_connecting_dialog_closed() -> void:
	close_connection()


func _on_connection_failed() -> void:
	close_connection()
	_notify_user("Failed to connect")


func _on_server_disconnected() -> void:
	close_connection()
	_notify_user("Disconnected from server")
