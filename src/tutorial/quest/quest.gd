class_name Quest
extends Resource

signal started
signal completed

@export_multiline var objective: String
@export var is_started := false:
	set = set_is_started
@export var is_completed := false:
	set = set_is_completed


func start() -> void:
	is_started = true


func complete() -> void:
	is_completed = true


func set_is_started(value: bool) -> void:
	var was_started: bool = is_started
	is_started = value
	if is_started and not was_started:
		started.emit()


func set_is_completed(value: bool) -> void:
	var was_completed: bool = is_completed
	is_completed = value and is_started
	if is_completed and not was_completed:
		completed.emit()
