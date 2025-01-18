class_name QuestNode
extends Node

signal started
signal completed

@export var quest: Quest

var is_started: bool:
	get = get_is_started, set = set_is_started
var is_completed: bool:
	get = get_is_completed, set = set_is_completed


func _ready() -> void:
	quest.started.connect(func() -> void: started.emit())
	quest.completed.connect(func() -> void: completed.emit())


func start() -> void:
	quest.start()


func complete() -> void:
	quest.complete()


func get_is_started() -> bool:
	return quest.is_started


func set_is_started(value: bool) -> void:
	quest.set_is_started(value)


func get_is_completed() -> bool:
	return quest.is_completed


func set_is_completed(value: bool) -> void:
	quest.set_is_completed(value)
