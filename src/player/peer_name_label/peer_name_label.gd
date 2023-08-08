extends Label


@export var player: Player


func _ready() -> void:
	player.peer_id_changed.connect(_on_peer_id_changed)
	_on_peer_id_changed(player.peer_id)


func _on_peer_id_changed(id: int) -> void:
	text = PeerData.peer_names.get(id, "")
	visible = id != multiplayer.get_unique_id()
