extends Node


signal pause_detected
signal unpause_detected

var _was_paused := false


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(_delta: float) -> void:
	var paused := get_tree().paused
	match [paused, _was_paused]:
		[false, true]:
			unpause_detected.emit()

		[true, false]:
			pause_detected.emit()

	_was_paused = paused
