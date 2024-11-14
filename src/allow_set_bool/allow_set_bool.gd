extends Node

@export var is_allowed := false:
	set = set_is_allowed

@export var node: Node

@export_group("Boolean Property", "property")
@export var property_name: StringName
@export var property_value := false:
	set = set_property_value


func _ready() -> void:
	_update_bool()


func set_is_allowed(value: bool) -> void:
	is_allowed = value
	_update_bool()


func set_property_value(value: bool) -> void:
	property_value = value
	_update_bool()


func _update_bool() -> void:
	if node == null:
		return

	if not node.is_node_ready():
		await node.ready

	if not is_allowed:
		return

	node.set(property_name, property_value)
