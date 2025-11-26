class_name GodotSplashScreen
extends Control

signal finished

@export var fade_duration: float = 0.4
@export var show_duration: float = 1.6

var _tween: Tween

@onready var color_rect: ColorRect = $ColorRect


func _ready() -> void:
	set_process_input(false)


func _input(event: InputEvent) -> void:
	if _tween == null:
		return

	if not _tween.is_running():
		return

	if (
			event is InputEventKey
			or event is InputEventMouseButton
			or event is InputEventJoypadButton
	):
		skip()


func start() -> void:
	const ALPHA_PROPERTY = ^"color:a"
	_tween = create_tween()
	_tween.finished.connect(_on_tween_finished)
	_tween.tween_property(color_rect,ALPHA_PROPERTY, 0.0, fade_duration)
	_tween.tween_interval(show_duration)
	_tween.tween_property(color_rect,ALPHA_PROPERTY, 1.0, fade_duration)
	set_process_input(true)


func skip() -> void:
	if _tween != null:
		_tween.kill()

	_on_tween_finished()


func _on_tween_finished() -> void:
	set_process_input(false)
	_tween = null
	finished.emit()
