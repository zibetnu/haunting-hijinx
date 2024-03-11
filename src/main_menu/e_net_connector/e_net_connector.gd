extends Node


signal client_created
signal server_created
signal create_client_failed
signal create_server_failed

@export var address := "localhost"
@export var port := 9999


func create_client() -> void:
	var peer := ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		create_client_failed.emit()
		return

	multiplayer.multiplayer_peer = peer
	client_created.emit()


func create_server() -> void:
	var peer := ENetMultiplayerPeer.new()
	peer.create_server(port)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		create_server_failed.emit()
		return

	multiplayer.multiplayer_peer = peer
	server_created.emit()


func set_address(value: String) -> void:
	address = value


func set_port_from_string(value: String) -> void:
	port = int(value)
