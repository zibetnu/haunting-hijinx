class_name Menu
extends Control

@warning_ignore("unused_signal")
signal pressed_sound_requested

@export var first_button: Button


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	if visible:
		first_button.grab_focus()


func _on_visibility_changed() -> void:
	if visible:
		first_button.grab_focus()
