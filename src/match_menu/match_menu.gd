extends Control


const OPEN_MENU_ACTION = &"open_menu"

@export var focus_first: Button


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(OPEN_MENU_ACTION):
		visible = not visible
		focus_first.grab_focus()  # No harm in calling this when not visible.

	if visible:
		accept_event()
