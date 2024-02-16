extends Node


@export var character: CharacterBody2D
@export var speed := 128.0
@export var manual_process := false:
	set(value):
		manual_process = value
		set_physics_process(not manual_process)

var move_vector: Vector2


func _ready() -> void:
	set_physics_process(not manual_process)


func _physics_process(delta: float) -> void:
	manual_physics_process(delta)


func manual_physics_process(_delta: float) -> void:
	character.velocity = move_vector * speed
	character.move_and_slide()


func set_move_vector(value: Vector2) -> void:
	move_vector = value
