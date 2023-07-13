class_name ExitTrigger
extends  Node


signal triggered

@export var trigger_on_exit: State
@export var state_machine: StateMachine

var _entered_trigger_state := false


func _ready() -> void:
	state_machine.transitioned.connect(_on_state_machine_transitioned)


func _on_state_machine_transitioned(state_name: String) -> void:
	if state_name == trigger_on_exit.name:
		_entered_trigger_state = true

	elif _entered_trigger_state:
		_entered_trigger_state = false
		triggered.emit()
