extends Node


const LOOP_POSITION = 19.79

@export var scene_names: Array[StringName]

var _scenes_present := 0:
	set = _set_scenes_present

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var timer: Timer = $Timer


func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)


func _set_scenes_present(value: int) -> void:
	_scenes_present = value
	if _scenes_present <= 0:
		timer.start()
		return

	timer.stop()
	if audio_stream_player.is_playing():
		return

	audio_stream_player.play()


func _on_node_added(node: Node) -> void:
	if node.name not in scene_names:
		return

	_scenes_present += 1
	node.tree_exiting.connect(func() -> void: _scenes_present -= 1)


func _on_timer_timeout() -> void:
	if _scenes_present > 0:
		return

	audio_stream_player.stop()


func _on_audio_stream_player_finished() -> void:
	audio_stream_player.play(LOOP_POSITION)
