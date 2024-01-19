extends StateComponent


@export var canvas_item: CanvasItem


func _on_state_entered() -> void:
	canvas_item.visible = true


func _on_state_exited() -> void:
	canvas_item.visible = false
