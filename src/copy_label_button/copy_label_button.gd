extends Button


@export var label: Label


func _on_pressed() -> void:
	DisplayServer.clipboard_set(label.text)
