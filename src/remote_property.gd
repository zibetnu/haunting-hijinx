class_name RemoteProperty
extends Node


enum ProcessCallback {
	PHYSICS,
	IDLE,
	NONE,
}

@export_group("Source", "source")
@export var source_node: Node
@export var source_property: StringName

@export_group("Destination", "destination")
@export var destination_node: Node
@export var destination_property: StringName

@export var process_callback := ProcessCallback.IDLE:
	set(value):
		process_callback = value
		set_physics_process(process_callback == ProcessCallback.PHYSICS)
		set_process(process_callback == ProcessCallback.IDLE)


func _ready() -> void:
	set_physics_process(process_callback == ProcessCallback.PHYSICS)
	set_process(process_callback == ProcessCallback.IDLE)


func manual_process() -> void:
	_set_property()


func _physics_process(_delta: float) -> void:
	_set_property()


func _process(_delta: float) -> void:
	_set_property()


func _set_property() -> void:
	destination_node.set(destination_property, source_node.get(source_property))
