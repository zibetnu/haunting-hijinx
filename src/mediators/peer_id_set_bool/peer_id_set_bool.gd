extends Node


enum Mode {
	THIS_PEER_ONLY,
	OTHER_PEERS_ONLY,
}

@export var peer_id: PeerID:
	set(value):
		if peer_id:
			peer_id.changed.disconnect(_on_peer_id_changed)

		peer_id = value
		if peer_id:
			peer_id.changed.connect(_on_peer_id_changed)

@export var false_for := Mode.OTHER_PEERS_ONLY
@export var node: Node

@export_group("Boolean Property", "property")
@export var property_name: StringName
@export var property_value := false:
	set(value):
		property_value = value
		_update_bool()

var _is_ready := false


func _ready() -> void:
	_is_ready = true
	_update_bool()


func set_value_false() -> void:
	property_value = false


func set_value_true() -> void:
	property_value = true


func _on_peer_id_changed(_id: int) -> void:
	_update_bool()


func _update_bool() -> void:
	if not _is_ready:
		return

	if false_for == Mode.THIS_PEER_ONLY:
		node.set(property_name, property_value or peer_id.id != multiplayer.get_unique_id())

	else:
		node.set(property_name, property_value or peer_id.id == multiplayer.get_unique_id())
