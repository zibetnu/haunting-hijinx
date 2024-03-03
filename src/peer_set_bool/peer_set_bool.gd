extends Node


enum Mode {
	LOCAL_PEER_ONLY,
	OTHER_PEERS_ONLY,
}

@export var is_local_peer := true:
	set(value):
		is_local_peer = value
		_update_bool()

@export var false_for := Mode.OTHER_PEERS_ONLY
@export var node: Node

@export_group("Boolean Property", "property")
@export var property_name: StringName
@export var property_value := false:
	set(value):
		property_value = value
		_update_bool()


func _ready() -> void:
	_update_bool()


func set_is_local_peer(value: bool) -> void:
	is_local_peer = value


func set_is_local_peer_false() -> void:
	is_local_peer = false


func set_is_local_peer_true() -> void:
	is_local_peer = true


func set_value_false() -> void:
	property_value = false


func set_value_true() -> void:
	property_value = true


func _update_bool() -> void:
	if not is_node_ready():
		await ready

	if false_for == Mode.LOCAL_PEER_ONLY:
		node.set(property_name, property_value or not is_local_peer)

	else:
		node.set(property_name, property_value or is_local_peer)
