extends Controller

const HIGH_INTENSITY = 2

@export var ghost: Node2D

var alert_intensity := 0

@onready var flashlight_timer: Timer = $FlashlightTimer
@onready var look_timer: Timer = $LookTimer


func _physics_process(delta: float) -> void:
	update_flashlight()
	update_look(delta)


func update_flashlight() -> void:
	if alert_intensity >= HIGH_INTENSITY:
		flashlight_timer.stop()
		button_1 = true
		return

	if alert_intensity > 0:
		if flashlight_timer.is_stopped():
			flashlight_timer.start(randf_range(0.0, 2.0))

		return

	button_1 = false


func update_look(delta: float) -> void:
	if ghost.modulate.a == 1.0:
		look_timer.stop()
		look_vector = Vector2.from_angle(get_angle_to(ghost.position))
		return

	if alert_intensity >= HIGH_INTENSITY:
		look_timer.stop()
		look_vector = look_vector.rotated(TAU * delta)
		return

	if alert_intensity > 0:
		if look_timer.is_stopped():
			look_timer.start(randf_range(0.0, 2.0))

		return

	if look_timer.is_stopped():
		look_timer.start(randf_range(2.0, 5.0))


func _on_sensed_intensity_changed(intensity: int) -> void:
	alert_intensity = intensity


func _on_flashlight_timer_timeout() -> void:
	button_1 = not button_1


func _on_look_timer_timeout() -> void:
	look_vector = Vector2.from_angle(randf_range(0.0, TAU))
