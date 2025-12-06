class_name SteamGamepadLineEdit
extends LineEdit

@export var description: String


func _ready() -> void:
	gui_input.connect(_on_gui_input)


func _exit_tree() -> void:
	Steam.dismissGamepadTextInput()


func _on_gamepad_text_input_dismissed(submitted: bool, new_text: String, _app_id: int) -> void:
	if submitted:
		text = new_text
		text_changed.emit(text)


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_accept") and not is_editing():
		accept_event()
		edit()
		if not Steam.isSteamInBigPictureMode():
			return

		var dismiss_signal: Signal = Steam.gamepad_text_input_dismissed
		var dismiss_callback: Callable = _on_gamepad_text_input_dismissed
		if not dismiss_signal.is_connected(dismiss_callback):
			dismiss_signal.connect(dismiss_callback, CONNECT_ONE_SHOT)

		Steam.showGamepadTextInput(
				Steam.GAMEPAD_TEXT_INPUT_MODE_NORMAL,
				Steam.GAMEPAD_TEXT_INPUT_LINE_MODE_SINGLE_LINE,
				description,
				max_length if max_length > 0 else -1,
				text
		)

	elif event.is_action_pressed(&"ui_cancel") and is_editing():
		accept_event()
		unedit()
		Steam.dismissGamepadTextInput()
