class_name GhostStatue
extends StaticBody2D

signal started_watching(target_path: NodePath)
signal stopped_watching

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

var _target: Node2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var area: Area2D = $Area2D
@onready var eyes: AnimatedSprite2D = $Eyes
@onready var look_timer: Timer = $LookTimer


func _ready() -> void:
	# Auto-generated tile names differ on each peer, which breaks
	# multiplayer syncing. This ensures that tiles are consistently
	# named "GhostStatue", "GhostStatue2", and so on.
	name = "GhostStatue"

	set_physics_process(false)
	if multiplayer.is_server():
		area.body_entered.connect(_on_area_body_entered)
		area.body_exited.connect(_on_area_body_exited)
		look_timer.timeout.connect(_on_look_timer_timeout)
		GhostStatueRPCs.register_statue(self)


func _physics_process(_delta: float) -> void:
	if _target == null:
		set_physics_process(false)
		return

	var angle_to: float = collision_shape.global_position.angle_to_point(
			_target.global_position
	)
	var index: int = posmod(
			roundi(angle_to / TAU * OFFSETS.size()),
			OFFSETS.size()
	)
	eyes.offset = OFFSETS[index]


func start_watching(target_path: NodePath) -> void:
	_target = get_node(target_path)
	if not eyes.visible:
		eyes.show()
		eyes.play(SHOW_ANIMATION)

	set_physics_process(true)
	started_watching.emit(target_path)


func stop_watching() -> void:
	_target = null
	if eyes.visible:
		eyes.play_backwards(SHOW_ANIMATION)

	look_timer.stop()
	stopped_watching.emit()


func _on_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group(&"hunters"):
		return

	if _target != null:
		return

	_target = body
	look_timer.start()


func _on_area_body_exited(body: Node2D) -> void:
	if body == _target:
		stop_watching()


func _on_look_timer_timeout() -> void:
	start_watching(_target.get_path())


func _on_eyes_animation_finished() -> void:
	if eyes.frame == 0:
		eyes.hide()
