extends Node


@export var min_pitch_scale: float = 0.8
@export var max_pitch_scale: float = 1.2

@onready var _audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func _enter_tree() -> void:
	get_tree().node_added.connect(_on_node_added)


func play_for_slider(slider: Slider) -> void:
	_audio_stream_player.pitch_scale = remap(
			slider.value,
			slider.min_value,
			slider.max_value,
			min_pitch_scale,
			max_pitch_scale
	)
	_audio_stream_player.play()


func _play_pitched(pitch_scale: float) -> void:
	_audio_stream_player.pitch_scale = pitch_scale
	_audio_stream_player.play()


func _on_node_added(node: Node) -> void:
	var slider := node as Slider
	if slider == null:
		return

	slider.value_changed.connect(
			func(_value: float) -> void: play_for_slider(slider)
	)
