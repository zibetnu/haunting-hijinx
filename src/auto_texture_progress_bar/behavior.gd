extends Node


@export var source_node: Node:
	set(value):
		source_node = value
		if _is_ready:
			_check_variables()

@export var value_variable: String:
	set(value):
		value_variable = value
		if _is_ready:
			_check_variables()

@export var max_variable: String:
	set(value):
		max_variable = value
		if _is_ready:
			_check_variables()

var _is_ready := false

@onready var bar: TextureProgressBar = get_parent()


func _ready() -> void:
	_is_ready = true
	_check_variables()


func _check_variables() -> void:
	var all_valid := (
			source_node != null
			and source_node.get(value_variable) != null
			and source_node.get(max_variable) != null
	)
	set_process(all_valid)
	if all_valid:
		bar.max_value = source_node.get(max_variable)


func _process(_delta: float) -> void:
	bar.value = source_node.get(value_variable)
