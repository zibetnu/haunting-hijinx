extends Node


@export var peer_id: PeerID:
	set(value):
		if peer_id:
			peer_id.changed.disconnect(_on_peer_id_changed)

		peer_id = value
		if peer_id:
			peer_id.changed.connect(_on_peer_id_changed)

@export var target: CanvasItem
@export var invert := false


func _on_peer_id_changed(id: int) -> void:
	if invert:
		target.visible = not id == multiplayer.get_unique_id()

	else:
		target.visible = id == multiplayer.get_unique_id()
