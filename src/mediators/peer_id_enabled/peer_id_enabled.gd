extends Node


@export var peer_id: PeerID:
	set(value):
		if peer_id:
			peer_id.changed.disconnect(_on_peer_id_changed)

		peer_id = value
		if peer_id:
			peer_id.changed.connect(_on_peer_id_changed)

@export var target: Node


func _on_peer_id_changed(id: int) -> void:
	target.set("enabled", multiplayer.get_unique_id() == id)
