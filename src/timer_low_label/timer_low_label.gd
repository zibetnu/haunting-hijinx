extends Label
## Pulses for every whole second less than [param low_threshold], including 0.


@export var timer: Timer
@export var low_threshold := 4

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _last_pulse_time: int = low_threshold


func _ready() -> void:
	set_physics_process(timer.process_callback == Timer.TIMER_PROCESS_PHYSICS)
	set_process(timer.process_callback == Timer.TIMER_PROCESS_IDLE)


func _physics_process(_delta: float) -> void:
	_update()


func _process(_delta: float) -> void:
	_update()


func _update() -> void:
	var floored_time: int = floori(timer.time_left)
	if not floored_time < _last_pulse_time:
		return

	text = str(floored_time)
	_animation_player.play("pulse")
	_last_pulse_time = floored_time
