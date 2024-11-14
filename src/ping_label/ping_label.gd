extends Label


func _on_timer_timeout() -> void:
	var last_rtt := 0.0
	var last_variance := 0.0
	var mean_rtt := 0.0
	var mean_variance := 0.0
	var peer := multiplayer.multiplayer_peer as ENetMultiplayerPeer
	if not multiplayer.is_server() and peer:
		var server := peer.get_peer(1)
		last_rtt = server.get_statistic(
				ENetPacketPeer.PEER_LAST_ROUND_TRIP_TIME
		)
		last_variance = server.get_statistic(
				ENetPacketPeer.PEER_LAST_ROUND_TRIP_TIME_VARIANCE
		)
		mean_rtt = server.get_statistic(ENetPacketPeer.PEER_ROUND_TRIP_TIME)
		mean_variance = server.get_statistic(
				ENetPacketPeer.PEER_ROUND_TRIP_TIME_VARIANCE
		)

	text = "Last: %s ± %s; Mean: %s ± %s" % [
		last_rtt, last_variance, mean_rtt, mean_variance
	]
