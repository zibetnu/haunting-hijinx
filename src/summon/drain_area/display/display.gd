extends Node2D


signal idle_started
signal active_started

enum Mode {
	IDLE,
	ACTIVE,
	COLLIDED,
}

const IDLE_ANIMATION = &"idle"
const ACTIVE_ANIMATION = &"active"
const COLLIDED_ANIMATION = &"collided"

@export var mode: Mode:
	set = set_mode

@onready var _animation_player: AnimationPlayer = $Waves/AnimationPlayer


func _ready() -> void:
	set_idle()


func collide() -> void:
	set_mode(Mode.COLLIDED)


func set_active() -> void:
	set_mode(Mode.ACTIVE)


func set_idle() -> void:
	set_mode(Mode.IDLE)


func set_mode(value: Mode) -> void:
	mode = value
	match mode:
		Mode.IDLE:
			_animation_player.play(IDLE_ANIMATION)
			idle_started.emit()

		Mode.ACTIVE:
			_animation_player.play(ACTIVE_ANIMATION)
			active_started.emit()

		Mode.COLLIDED:
			_animation_player.play(COLLIDED_ANIMATION)
			active_started.emit()
