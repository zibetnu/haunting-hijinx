extends Node


var _cutscene_in_progress := false


@rpc("call_local")
func play_cutscene(cutscene_name: String, time: float) -> void:
	if _cutscene_in_progress:
		return

	_cutscene_in_progress = true
	get_tree().call_group("cutscene_sync", "_on_cutscene_started", cutscene_name)
	await get_tree().create_timer(time).timeout
	get_tree().call_group("cutscene_sync", "_on_cutscene_ended", cutscene_name)
	_cutscene_in_progress = false
