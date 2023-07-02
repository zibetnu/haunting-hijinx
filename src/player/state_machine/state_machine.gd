class_name StateMachine
extends Node


signal transitioned(state_name)

@export var player: Player
@export var state: State


func _ready() -> void:
	await player.ready
	for child in get_children():
		if not child is State:
			continue

		child.state_machine = self
		child.player = player

	state.enter()
	emit_signal("transitioned", state.name)


func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)


func _process(delta: float) -> void:
	state.update(delta)


func _physics_process(delta: float) -> void:
	state.physics_update(delta)


func handle_damage(source: DamageSource) -> void:
	state.handle_damage(source)


@rpc("call_local")
func transition_to(target_state_name: String, message: Dictionary = {}) -> void:
	if not has_node(target_state_name):
		return

	if state.name == target_state_name:
		return

	state.exit()
	state = get_node(target_state_name)
	state.enter(message)
	emit_signal("transitioned", state.name)
