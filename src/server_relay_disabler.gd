extends Node


func _ready() -> void:
	# Disable server relay to ensure that data is only shared between clients when necessary.
	multiplayer.server_relay = false
