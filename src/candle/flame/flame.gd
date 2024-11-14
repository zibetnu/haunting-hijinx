extends Sprite2D

@export var random_delay := true
@export_range(0, 1, 0.01) var delay_max_sec := 0.5

@onready var _animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	await get_tree().create_timer(randf_range(0, delay_max_sec)).timeout
	_animation_player.play("candle")
