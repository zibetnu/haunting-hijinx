extends Label


func _ready() -> void:
	ConnectionManager.ping_set.connect(_on_ping_set)


func _on_ping_set(ping: int) -> void:
	text = "%s ms" % ping


func _on_timer_timeout() -> void:
	if multiplayer.is_server():
		return

	ConnectionManager.get_ping.rpc_id(1, Time.get_ticks_usec())
