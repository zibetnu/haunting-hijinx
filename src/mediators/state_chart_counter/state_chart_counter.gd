extends Node


@export var counter: int:
	set(value):
		counter = value
		_set_expression_property()

@export var counter_name: StringName
@export var state_chart: StateChart


func _ready() -> void:
	_set_expression_property()


func _set_expression_property() -> void:
	if state_chart:
		state_chart.set_expression_property(counter_name, counter)
