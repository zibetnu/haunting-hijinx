extends Node


signal property_changed(property: StringName, value: Variant)

@export var property_name: StringName

var property_value: Variant:
	set(value):
		property_value = value
		property_changed.emit(property_name, property_value)


func set_property_name(value: StringName) -> void:
	property_name = value


func set_property_value(value: Variant) -> void:
	property_value = value
