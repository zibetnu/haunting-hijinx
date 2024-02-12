extends Label


@export var peer_id := 1:
	set(value):
		peer_id = value
		text = PeerData.peer_names.get(value, "")


func set_peer_id(id: int) -> void:
	peer_id = id
