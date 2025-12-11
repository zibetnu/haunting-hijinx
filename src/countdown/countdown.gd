extends Control
## Pulses for every whole second less than [param low_threshold], including 0.

@export var timer: TimerSprite
@export var low_threshold := 4

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _last_pulse_time: int = low_threshold
@onready var _sprite_2d: Sprite2D = $Sprite2D


func _physics_process(_delta: float) -> void:
	_update()


func _process(_delta: float) -> void:
	_update()


func _update() -> void:
	var floored_time: int = floori(timer.time_left)
	if not floored_time < _last_pulse_time:
		return

	_sprite_2d.frame = floored_time % _sprite_2d.hframes
	_animation_player.play("pulse")
	_last_pulse_time = floored_time
