extends Control


@export var states: Array[State] = []
@export var state_machine: StateMachine

@onready var _state_names := states.map(func(state): return state.name)


func _ready() -> void:
	state_machine.transitioned.connect(_on_state_machine_transitioned)


func _on_state_machine_transitioned(state_name: String) -> void:
	visible = state_name in _state_names
