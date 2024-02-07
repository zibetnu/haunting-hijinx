extends Area2D


signal grabbed


func grab() -> void:
	grabbed.emit()
	print("wow!")
