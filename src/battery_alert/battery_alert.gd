extends Control


@onready var animation_player: AnimationPlayer = $AnimationPlayer


func notify_dead() -> void:
	animation_player.play("battery_dead")


func notify_low() -> void:
	animation_player.play("battery_low")


func notify_none() -> void:
	animation_player.play("RESET")
