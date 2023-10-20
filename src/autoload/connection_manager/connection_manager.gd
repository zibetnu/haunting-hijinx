extends Node


signal client_created
signal connection_closed
signal ping_set(ping: int)
signal server_created

var ping := 0  # RTT in milliseconds.

@export var dedicated_port := 9999


func _ready() -> void:
	# Disable server relay to ensure that data is only shared between clients when necessary.
	multiplayer.server_relay = false
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	if DisplayServer.get_name() == "headless":
		print("Starting dedicated server")
		create_server(dedicated_port)


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


func create_server(port: int) -> void:
	var peer := ENetMultiplayerPeer.new()
	peer.create_server(port)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		_notify_user("Failed to create server")
		return

	multiplayer.multiplayer_peer = peer
	server_created.emit()


@rpc("any_peer")
func get_ping(ticks_usec: int) -> void:
	if not multiplayer.is_server():
		return

	var id := multiplayer.get_remote_sender_id()
	set_ping.rpc_id(id, ticks_usec)


@rpc
func set_ping(ticks_usec: int) -> void:
	ping = round((Time.get_ticks_usec() - ticks_usec) / 1000.0)
	ping_set.emit(ping)


func _notify_user(message: String) -> void:
	$AcceptDialog.dialog_text = message
	$AcceptDialog.popup_centered()
	print(message)


func _on_connection_failed() -> void:
	_notify_user("Failed to connect")


func _on_server_disconnected() -> void:
	close_connection()
	_notify_user("Disconnected from server")
