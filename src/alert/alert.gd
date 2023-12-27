class_name Alert
extends Control


enum AlertLevel {
	NONE,
	LOW,
	HIGH,
}

@export var alert_level: AlertLevel:
	set(value):
		alert_level = value
		if _is_ready:
			_update_animation()

var _is_ready := false

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	_update_animation()
	_is_ready = true


func _update_animation() -> void:
	match alert_level:
		AlertLevel.NONE:
			animation_player.play("RESET")

		AlertLevel.LOW:
			animation_player.play("alert_low")

		AlertLevel.HIGH:
			animation_player.play("alert_high")
