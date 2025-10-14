class_name GhostStatue
extends StaticBody2D

const SHOW_ANIMATION = &"show"
const OFFSETS = [
	Vector2.RIGHT,
	Vector2.ONE,
	Vector2.DOWN,
	Vector2(-1.0, 1.0),
	Vector2.LEFT,
	Vector2(-1.0, -1.0),
	Vector2.UP,
	Vector2(1.0, -1.0),
]

var _hunter: Node2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var area: Area2D = $Area2D
@onready var eyes: AnimatedSprite2D = $Eyes
@onready var look_timer: Timer = $LookTimer


func _ready() -> void:
	set_physics_process(false)
	if multiplayer.is_server():
		area.body_entered.connect(_on_area_body_entered)
		area.body_exited.connect(_on_area_body_exited)
		look_timer.timeout.connect(_on_look_timer_timeout)


func _physics_process(_delta: float) -> void:
	if _hunter == null:
		set_physics_process(false)
		return

	var angle_to: float = collision_shape.global_position.angle_to_point(
			_hunter.global_position
	)
	var index: int = posmod(
			roundi(angle_to / TAU * OFFSETS.size()),
			OFFSETS.size()
	)
	eyes.offset = OFFSETS[index]


@rpc("authority", "call_local", "reliable")
func show_eyes() -> void:
	if not eyes.visible:
		eyes.show()
		eyes.play(SHOW_ANIMATION)


@rpc("authority", "call_local", "reliable")
func hide_eyes() -> void:
	_hunter = null
	if eyes.visible:
		eyes.play_backwards(SHOW_ANIMATION)

	look_timer.stop()


func _on_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group(&"hunters"):
		return

	if _hunter != null:
		return

	_hunter = body
	look_timer.start()


func _on_area_body_exited(body: Node2D) -> void:
	if body == _hunter:
		hide_eyes.rpc()


func _on_look_timer_timeout() -> void:
	show_eyes.rpc()
	set_physics_process(true)


func _on_eyes_animation_finished() -> void:
	if eyes.frame == 0:
		eyes.hide()
