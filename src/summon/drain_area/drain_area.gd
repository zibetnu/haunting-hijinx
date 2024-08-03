extends Node2D


# Godot crashes with signal 11 if the signal directly calls queue_free. This
# is a (hopefully temporary) workaround.
func queue_free_workaround() -> void:
	queue_free()
