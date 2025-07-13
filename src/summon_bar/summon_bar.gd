class_name SummonBar
extends Control

const PARTIAL_ANIMATION = &"partial"

@onready var bar: TextureProgressBar = $TextureProgressBar
@onready var highlight: AnimatedSprite2D = $CompletedHighlight

@onready var _tween: Tween


@rpc("reliable")
func start(time_sec: float) -> void:
	if multiplayer.is_server():
		start.rpc(time_sec)

	if _tween != null:
		_tween.kill()

	bar.value = 0
	_tween = get_tree().create_tween()
	_tween.finished.connect(_on_tween_finished)
	_tween.tween_property(bar, ^"value", bar.max_value, time_sec)
	_tween.play()

	highlight.sprite_frames.set_animation_speed(
			PARTIAL_ANIMATION,
			time_sec / (highlight.sprite_frames.get_frame_count(PARTIAL_ANIMATION) - 1)
	)
	highlight.play(PARTIAL_ANIMATION)


@rpc("reliable")
func stop() -> void:
	if multiplayer.is_server():
		stop.rpc()

	if _tween != null:
		_tween.kill()

	bar.value = 0
	highlight.sprite_frames.set_animation_speed(PARTIAL_ANIMATION, 0)
	highlight.play(PARTIAL_ANIMATION)
	highlight.frame = 0


func _on_tween_finished() -> void:
	highlight.play(&"complete")
