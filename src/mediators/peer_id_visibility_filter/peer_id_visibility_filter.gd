extends Node


signal filter_enabled
signal filter_disabled

@export var peer_id: PeerID
@export var synchronizer: MultiplayerSynchronizer
@export var enable_filter := true:
	set(value):
		enable_filter = value
		if value:
			filter_enabled.emit()

		else:
			filter_disabled.emit()

@export var include_ghost_peer := false

var _filter = func(id):
		return (
				not enable_filter
				or id == peer_id.id
				or (include_ghost_peer and id == PeerData.ghost_peer)
		)


func _ready() -> void:
	synchronizer.add_visibility_filter(_filter)


func disable() -> void:
	enable_filter = false


func enable() -> void:
	enable_filter = true
