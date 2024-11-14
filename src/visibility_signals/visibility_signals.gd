extends Node

signal hidden
signal shown
signal visibility_changed(visible: bool)

@export var canvas_item: CanvasItem:
	set = set_canvas_item


func set_canvas_item(value: CanvasItem) -> void:
	var receiver_method: Callable = _on_canvas_item_visibility_changed
	if canvas_item != null:
		var old_signal: Signal = canvas_item.visibility_changed
		if old_signal.is_connected(receiver_method):
			old_signal.disconnect(receiver_method)

	if value == null:
		return

	canvas_item = value
	canvas_item.visibility_changed.connect(receiver_method)


func _on_canvas_item_visibility_changed() -> void:
	var visible := canvas_item.visible
	(shown if visible else hidden).emit()
	visibility_changed.emit(visible)
