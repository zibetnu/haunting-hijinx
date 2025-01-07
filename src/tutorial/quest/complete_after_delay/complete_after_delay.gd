extends Node

@export var quest: Quest
@export_range(0.001, 4096, 0.001, "exp", "suffix:s") var delay := 1.0

var _queued := false

@onready var timer: Timer = $Timer


func _ready() -> void:
	quest.started.connect(_start_if_queued)


func start() -> void:
	if not quest.is_started:
		_queued = true
		return

	timer.start(delay)


func stop() -> void:
	_queued = false
	timer.stop()


func _start_if_queued() -> void:
	if not _queued:
		return

	start()


func _on_timer_timeout() -> void:
	quest.complete()
	_queued = false
