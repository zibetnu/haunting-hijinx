extends Label


@export var state_machine: StateMachine


func _ready() -> void:
	state_machine.transitioned.connect(_on_transitioned)


func _on_transitioned(state_name: String) -> void:
	text = state_name
