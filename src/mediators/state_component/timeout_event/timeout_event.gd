class_name TimeoutEvent
extends StateComponent


@export var event: StringName
@export var state_chart: StateChart
@export var wait_time := 1.0

@onready var timer := $Timer


func _ready() -> void:
	timer.timeout.connect(_on_timeout)


func _on_state_entered() -> void:
	timer.start(wait_time)


func _on_state_exited() -> void:
	timer.stop()


func _on_timeout() -> void:
	if state_chart:
		state_chart.send_event(event)
