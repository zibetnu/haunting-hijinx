extends Sprite2D

@onready var _animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	const CANDLE = &"candle"
	_animation_player.play(CANDLE)
	_animation_player.seek(
			_animation_player.get_animation(CANDLE).length * randf()
	)
