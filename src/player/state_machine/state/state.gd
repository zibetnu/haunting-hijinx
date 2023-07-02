class_name State
extends Node


@export var damage_handler: DamageHandler

var player: Player = null
var state_machine: StateMachine = null


func handle_damage(source: DamageSource) -> void:
	if not damage_handler:
		return

	damage_handler.handle_damage(source, player)


func handle_input(_event: InputEvent) -> void:
	pass


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func enter(_message := {}) -> void:
	pass


func exit() -> void:
	pass
