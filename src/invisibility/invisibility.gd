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

	if visible and not while_visible.is_multiplayer_authority():
		await while_visible.synchronized

	visibility_changed.emit(visible)


func _visibility_filter(peer_id: int) -> bool:
	return visible or peer_id == local_peer_id
