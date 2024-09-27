extends Node


signal visibility_changed(value: bool)

@export var local_peer_id: int = 1:
	set = set_local_peer_id
@export var visible: bool:
	set = set_visible

@onready var while_visible: MultiplayerSynchronizer = $WhileVisible


func _ready() -> void:
	while_visible.add_visibility_filter(_visibility_filter)


func set_local_peer_id(value: int) -> void:
	local_peer_id = value


func set_visible(value: bool) -> void:
	visible = value
	var is_local: bool = local_peer_id == multiplayer.get_unique_id()
	if is_local:
		return

	await _await_synchronization()
	visibility_changed.emit(visible)


func _visibility_filter(peer_id: int) -> bool:
	return visible or peer_id == local_peer_id


func _await_synchronization() -> void:
	if not visible:
		return

	if while_visible.is_multiplayer_authority():
		return

	if while_visible.replication_config.get_properties().size() < 1:
		return

	await while_visible.synchronized
