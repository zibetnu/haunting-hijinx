extends Node


@export var peer_id: PeerID:
	set(value):
		if peer_id:
			peer_id.changed.disconnect(_on_peer_id_changed)

		peer_id = value
		if peer_id:
			peer_id.changed.connect(_on_peer_id_changed)


@export var synchronizer: MultiplayerSynchronizer


func _ready() -> void:
	synchronizer.public_visibility = false


func _on_peer_id_changed(id: int) -> void:
	for connected_peer_id in multiplayer.get_peers():
		synchronizer.set_visibility_for(
				connected_peer_id,
				connected_peer_id == id or connected_peer_id == PeerData.ghost_peer
		)
