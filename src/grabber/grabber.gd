extends Area2D


signal grabbable_grabbed


func attempt_grab_on(target: Node) -> void:
	if target.has_method("grab"):
		target.grab()
		grabbable_grabbed.emit()
