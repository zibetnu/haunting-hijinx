extends Control


@export var flashlight: Flashlight:
	set(value):
		flashlight = value
		set_physics_process(flashlight != null)

var _was_battery_low := false


func _ready() -> void:
	set_physics_process(flashlight != null)


func  _physics_process(_delta: float) -> void:
	var is_battery_low := flashlight.is_battery_low and flashlight.battery > 0
	if not is_battery_low:
		visible = false

	elif not _was_battery_low:
		notify()

	_was_battery_low = is_battery_low


func notify() -> void:
	visible = flashlight.player.peer_id == multiplayer.get_unique_id()
	$Timer.start()


func _on_timer_timeout() -> void:
	visible = false
