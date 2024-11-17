extends Node

signal process_mode_updated(mode: Node.ProcessMode)

@export_group("Peer ID")
@export var primary_peer_id := 1:
	set(value):
		primary_peer_id = value
		_update_process_mode()

@export_subgroup("Secondary", "secondary")
@export var secondary_include := false
@export var secondary_peer_id := 1:
	set(value):
		secondary_peer_id = value
		_update_process_mode()

@export_group("Peer Process", "peer_process")
@export_enum("Inherit", "Pausable", "When Paused", "Always", "Disabled")
var peer_process_active_mode := 0
@export_enum("Inherit", "Pausable", "When Paused", "Always", "Disabled")
var peer_process_inactive_mode := 4


func set_primary_peer_id(id: int) -> void:
	primary_peer_id = id


func set_secondary_peer_id(id: int) -> void:
	secondary_peer_id = id


func _update_process_mode() -> void:
	var local_id := multiplayer.get_unique_id()
	if (
			local_id == primary_peer_id
			or (secondary_include and local_id == secondary_peer_id)
	):
		process_mode_updated.emit(peer_process_active_mode)

	else:
		process_mode_updated.emit(peer_process_inactive_mode)
