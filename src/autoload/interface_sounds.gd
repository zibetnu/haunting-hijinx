extends Node

var button_press: AudioStreamPlayer = new_audio_stream_player()
var slider_change: AudioStreamPlayer = new_audio_stream_player()
var signals_to_callables: Dictionary = {
	&"item_activated": button_press.play,
	&"pressed": button_press.play,
	&"pressed_sound_requested": button_press.play,
	&"tab_selected": func (_tab: int) -> void: button_press.play(),
}


func _init() -> void:
	add_child(button_press)
	add_child(slider_change)


func _enter_tree() -> void:
	get_tree().node_added.connect(_on_node_added)


func new_audio_stream_player() -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.bus = "Effects"
	player.stream = preload("uid://dyxlv1xko7tdx")  # Button press sound.
	return player


func play_for_slider(slider: Slider) -> void:
	slider_change.pitch_scale = remap(
			slider.value,
			slider.min_value,
			slider.max_value,
			0.8,
			1.2
	)
	slider_change.play()


func _on_node_added(node: Node) -> void:
	if node.owner == null:
		return

	if node.is_in_group(&"exclude_interface_sounds"):
		return

	if node is Slider:
		var slider: Slider = node
		slider.value_changed.connect(
				func (_value: float) -> void: play_for_slider(slider)
		)
		return

	for signal_name: StringName in signals_to_callables:
		if not node.has_signal(signal_name):
			continue

		var callable: Callable = signals_to_callables[signal_name]
		if node.is_connected(signal_name, callable):
			continue

		node.connect(signal_name, callable)
