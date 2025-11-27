class_name ReviveHeart
extends Control

@onready var animation_timeout: Timer = %AnimationTimeout
@onready var bar: TextureProgressBar = %Bar
@onready var outline: AnimatedSprite2D = %Outline


func set_progress(value: float) -> void:
	if not is_node_ready():
		return

	var clamped: float = clampf(value, 0.0, 1.0)
	var remapped: float = remap(clamped, 0.0, 1.0, bar.min_value, bar.max_value)
	var floored: int = floori(remapped)
	bar.value = floored
	start_animation()


@rpc("authority", "call_remote", "reliable")
func start_animation() -> void:
	if multiplayer.is_server():
		start_animation.rpc()

	outline.play(&"default")
	animation_timeout.start()


func reset() -> void:
	bar.value = bar.min_value
	outline.stop()
	animation_timeout.stop()


func _on_animation_timeout_timeout() -> void:
	outline.stop()
