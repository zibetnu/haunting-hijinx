extends Node


@export var peer_id: PeerID:
	set(value):
		if peer_id:
			peer_id.changed.disconnect(_on_peer_id_changed)

		peer_id = value
		if peer_id:
			peer_id.changed.connect(_on_peer_id_changed)

@export var synced_controller: SyncedController


func _on_peer_id_changed(id: int) -> void:
	if synced_controller:
		synced_controller.input_authority = id
