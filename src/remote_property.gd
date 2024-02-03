class_name RemoteProperty
extends Node


enum ProcessCallback {
	PHYSICS,
	IDLE,
	NONE,
}

@export var process_callback := ProcessCallback.IDLE:
	set(value):
		process_callback = value
		_update_process_callback()

@export_group("Source", "source")
@export var source_node: Node
@export var source_property: StringName

@export_group("Destination", "destination")
@export var destination_node: Node
@export var destination_property: StringName


func _ready() -> void:
	_update_process_callback()


func manual_process() -> void:
	_set_property()


func use_idle_callback() -> void:
	process_callback = ProcessCallback.IDLE


func use_physics_callback() -> void:
	process_callback = ProcessCallback.PHYSICS


func use_manual_callback_only() -> void:
	process_callback = ProcessCallback.NONE


func _physics_process(_delta: float) -> void:
	_set_property()


func _process(_delta: float) -> void:
	_set_property()


func _set_property() -> void:
	destination_node.set(destination_property, source_node.get(source_property))


func _update_process_callback() -> void:
	set_physics_process(process_callback == ProcessCallback.PHYSICS)
	set_process(process_callback == ProcessCallback.IDLE)
