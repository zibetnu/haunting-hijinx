extends Condition


@export var condition_1: Condition
@export var condition_2: Condition


func is_true() -> bool:
	return condition_1.is_true() and condition_2.is_true()
