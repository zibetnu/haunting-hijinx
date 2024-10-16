extends Control


const CANCEL_ACTION = &"ui_cancel"

@onready var back: Button = $HBoxContainer/VBoxContainer/HBoxContainer/Back


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed(CANCEL_ACTION):
		back.pressed.emit()
		accept_event()
