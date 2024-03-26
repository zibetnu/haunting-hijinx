extends Node


signal property_changed(property: StringName, value: Variant)

@export var emit_on_ready := false
@export var property_name: StringName
# Workaround for not being allowed to export Variant properties.
# See https://github.com/godotengine/godot/pull/33080.
@export var initial_property_value := [null]

@onready var property_value: Variant = initial_property_value[0]:
	set(value):
		property_value = value
		property_changed.emit(property_name, property_value)


func _ready() -> void:
	if emit_on_ready:
		property_changed.emit(property_name, property_value)


func set_property_name(value: StringName) -> void:
	property_name = value


func set_property_value(value: Variant) -> void:
	property_value = value
