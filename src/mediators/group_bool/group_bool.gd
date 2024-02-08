extends Node


signal is_true_set

@export var group: StringName
@export var is_true := false:
	set(value):
		is_true = value
		is_true_set.emit()


func _ready() -> void:
	get_tree().call_group(group, "_on_group_bool_ready", self)


func set_false() -> void:
	is_true = false


func set_true() -> void:
	is_true = true
