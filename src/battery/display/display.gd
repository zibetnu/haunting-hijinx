extends Node2D


signal spawned
signal destroyed

const BOB_NAME = &"bob"
const DESTROY_NAME = &"destroy"
const SPAWN_NAME = &"spawn"

@onready var _animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	spawn()


func destroy() -> void:
	_animation_player.play(DESTROY_NAME)
	await _animation_player.animation_finished
	destroyed.emit()


func spawn() -> void:
	_animation_player.play(SPAWN_NAME)
	await _animation_player.animation_finished
	_animation_player.play(BOB_NAME)
	spawned.emit()
