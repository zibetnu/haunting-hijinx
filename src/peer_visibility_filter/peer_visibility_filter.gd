extends Node

signal filter_enabled
signal filter_disabled
signal filter_ready(filter: Callable)

@export var enable_filter := true:
	set(value):
		enable_filter = value
		if value:
			filter_enabled.emit()

		else:
			filter_disabled.emit()

@export var primary_peer_id := 1

@export_group("Secondary", "secondary")
@export var secondary_peer_id := 1
@export var secondary_allow_in_filter := false

var _filter := func(id: int) -> bool:
	return (
			not enable_filter  # Always return true if filter is disabled.
			or id == primary_peer_id
			or (id == secondary_peer_id and secondary_allow_in_filter)
	)


func _ready() -> void:
	filter_ready.emit(_filter)


func disable() -> void:
	enable_filter = false


func enable() -> void:
	enable_filter = true


func set_primary_peer_id(id: int) -> void:
	primary_peer_id = id


func set_secondary_peer_id(id: int) -> void:
	secondary_peer_id = id
