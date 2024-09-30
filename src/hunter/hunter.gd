extends CharacterBody2D


const GRABBED_EVENT = &"died"

@export_group("State Collision", "state")
@export_flags_2d_physics var state_alive_layer: int
@export_flags_2d_physics var state_dead_layer: int
@export_flags_2d_physics var state_invulnerable_layer: int

@onready var state_chart: StateChart = $StateChart


func enable_alive_collision_layer() -> void:
	collision_layer = state_alive_layer


func enable_dead_collision_layer() -> void:
	collision_layer = state_dead_layer


func enable_invulnerable_collision_layer() -> void:
	collision_layer = state_invulnerable_layer


func on_grabbed() -> void:
	state_chart.send_event(GRABBED_EVENT)
