extends Condition


@export var action_name: String
@export var controller: Controller


func is_true() -> bool:
	return controller.is_action_pressed(action_name)
