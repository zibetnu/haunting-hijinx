class_name StateComponent
extends Node


@export var active_state: State:
	set(value):
		if active_state:
			_disconnect_signals(active_state)

		active_state = value
		if active_state:
			_connect_signals(active_state)


func _connect_signals(state: State) -> void:
		if not state.event_received.is_connected(_on_event_received):
			state.event_received.connect(_on_event_received)

		if not state.state_entered.is_connected(_on_state_entered):
			state.state_entered.connect(_on_state_entered)

		if not state.state_exited.is_connected(_on_state_exited):
			state.state_exited.connect(_on_state_exited)

		if not state.state_input.is_connected(_on_state_input):
			state.state_input.connect(_on_state_input)

		if not state.state_physics_processing.is_connected(_on_state_physics_processing):
			state.state_physics_processing.connect(_on_state_physics_processing)

		if not state.state_processing.is_connected(_on_state_processing):
			state.state_processing.connect(_on_state_processing)

		if not state.state_stepped.is_connected(_on_state_stepped):
			state.state_stepped.connect(_on_state_stepped)

		if not state.state_unhandled_input.is_connected(_on_state_unhandled_input):
			state.state_unhandled_input.connect(_on_state_unhandled_input)

		if not state.transition_pending.is_connected(_on_transition_pending):
			state.transition_pending.connect(_on_transition_pending)

func _disconnect_signals(state: State) -> void:
		if state.event_received.is_connected(_on_event_received):
			state.event_received.disconnect(_on_event_received)

		if state.state_entered.is_connected(_on_state_entered):
			state.state_entered.disconnect(_on_state_entered)

		if state.state_exited.is_connected(_on_state_exited):
			state.state_exited.disconnect(_on_state_exited)

		if state.state_input.is_connected(_on_state_input):
			state.state_input.disconnect(_on_state_input)

		if state.state_physics_processing.is_connected(_on_state_physics_processing):
			state.state_physics_processing.disconnect(_on_state_physics_processing)

		if state.state_processing.is_connected(_on_state_processing):
			state.state_processing.disconnect(_on_state_processing)

		if state.state_stepped.is_connected(_on_state_stepped):
			state.state_stepped.disconnect(_on_state_stepped)

		if state.state_unhandled_input.is_connected(_on_state_unhandled_input):
			state.state_unhandled_input.disconnect(_on_state_unhandled_input)

		if state.transition_pending.is_connected(_on_transition_pending):
			state.transition_pending.disconnect(_on_transition_pending)


func _on_state_entered() -> void:
	pass


func _on_state_exited() -> void:
	pass


func _on_event_received(_event: StringName) -> void:
	pass


func _on_state_processing(_delta: float) -> void:
	pass


func _on_state_physics_processing(_delta: float) -> void:
	pass


func _on_state_stepped() -> void:
	pass


func _on_state_input(_event: InputEvent) -> void:
	pass


func _on_state_unhandled_input(_event: InputEvent) -> void:
	pass


func _on_transition_pending(_initial_delay: float, _remaining_delay: float) -> void:
	pass
