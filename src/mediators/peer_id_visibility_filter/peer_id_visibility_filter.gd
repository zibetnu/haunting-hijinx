extends Node


@export var peer_id: PeerID:
	set(value):
		if peer_id:
			peer_id.changed.disconnect(_on_peer_id_changed)

		peer_id = value
		if peer_id:
			peer_id.changed.connect(_on_peer_id_changed)


@export var synchronizers: Array[MultiplayerSynchronizer]


func _ready() -> void:
	for synchronizer in synchronizers:
		synchronizer.public_visibility = false


func _on_peer_id_changed(id: int) -> void:
	for synchronizer in synchronizers:
		synchronizer.set_visibility_for(id, true)
