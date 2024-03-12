extends HBoxContainer


@onready var label: Label = $Label


func _on_copy_button_pressed() -> void:
	DisplayServer.clipboard_set(label.text)
