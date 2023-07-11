class_name ExitTrigger
extends Ability


@export var trigger_on_exit: State

var _entered_trigger_state := false


func _on_player_state_machine_transitioned(state_name: String) -> void:
	if state_name == trigger_on_exit.name:
		_entered_trigger_state = true

	elif state_name in _state_names and _entered_trigger_state:
		_entered_trigger_state = false
		_trigger()


func _trigger() -> void:
	pass
