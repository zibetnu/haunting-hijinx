extends Label


@export var timer: Timer


func _ready() -> void:
	set_physics_process(timer.process_callback == Timer.TIMER_PROCESS_PHYSICS)
	set_process(timer.process_callback == Timer.TIMER_PROCESS_IDLE)


func _physics_process(_delta: float) -> void:
	_update()


func _process(_delta: float) -> void:
	_update()


func _update() -> void:
	text = "%d:%02d" % [timer.time_left / 60, int(timer.time_left) % 60]
