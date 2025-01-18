extends MarginContainer

const CANCEL_ACTION = &"ui_cancel"

@export var ghost: Button
@export var hunter: Button
@export var back: Button


func _ready() -> void:
	ghost.pressed.connect(SceneChanger.change_to_ghost_tutorial)
	hunter.pressed.connect(SceneChanger.change_to_hunter_tutorial)


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed(CANCEL_ACTION):
		back.pressed.emit()
		accept_event()
