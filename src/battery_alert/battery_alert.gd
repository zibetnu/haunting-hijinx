extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var _timer: Timer = $Timer


func notify_dead() -> void:
	animation_player.play("battery_dead")
	_timer.start()


func notify_low() -> void:
	animation_player.play("battery_low")
	_timer.start()


func notify_none() -> void:
	animation_player.play("RESET")
	_timer.stop()
