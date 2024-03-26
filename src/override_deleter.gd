extends Node


func _ready() -> void:
	if not FileAccess.file_exists("override.cfg"):
		return

	DirAccess.remove_absolute("override.cfg")
	OS.alert("A file from a prior playtest was found and deleted. The game will now quit.")
	get_tree().quit()
