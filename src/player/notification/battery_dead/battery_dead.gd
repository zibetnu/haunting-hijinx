extends Control


@export var flashlight: Flashlight:
	set(value):
		flashlight = value
		set_physics_process(flashlight != null)

var _was_battery_dead := false


func  _physics_process(_delta: float) -> void:
	var is_battery_dead := flashlight.battery == 0
	if not is_battery_dead:
		visible = false

	elif (
			not _was_battery_dead
			or flashlight.player.controller.is_action_pressed(flashlight.action_name)
	):
		notify()

	_was_battery_dead = is_battery_dead


func notify() -> void:
	visible = flashlight.player.peer_id == multiplayer.get_unique_id()
	$Timer.start()


func _on_timer_timeout() -> void:
	visible = false
