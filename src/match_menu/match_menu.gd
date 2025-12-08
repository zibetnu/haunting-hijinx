class_name MatchMenu
extends Menu


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"open_menu"):
		visible = not visible

	if visible:
		accept_event()
