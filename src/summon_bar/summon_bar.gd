extends Control

@export var charge_time := 4.0

@onready var bar: TextureProgressBar = $TextureProgressBar
@onready var highlight: AnimatedSprite2D = $CompletedHighlight

@onready var _tween: Tween = create_tween()


func _ready() -> void:
	_tween.pause()


func set_as_ratio(value: float) -> void:
	bar.ratio = value


func _on_bar_value_changed(_value: float) -> void:
	if bar.ratio < 0.25:
		highlight.hide()
		return

	highlight.show()
	if bar.ratio == 1.0:
		highlight.play(&"complete")
		return

	highlight.play(&"partial_complete")
	var frame_count: int = highlight.sprite_frames.get_frame_count(&"partial_complete")
	highlight.frame = int(frame_count * bar.ratio) - 1


func _on_visibility_changed() -> void:
	if not is_inside_tree():
		return

	if multiplayer.is_server():
		return

	_tween.stop()
	if not visible:
		bar.value = 0
		return

	# Tween value on clients to avoid frequent updates over the network.
	_tween.tween_property(bar, ^"value", bar.max_value, charge_time)
	_tween.play()
