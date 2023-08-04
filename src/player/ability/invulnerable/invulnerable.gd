extends Ability


@export var duration := 4.0
@export var dead_exit_trigger: ExitTrigger
@export var player_alpha := 1.0:
	get:
		return player.modulate.a

	set(value):
		player.modulate.a = value

var _previous_collision_layer: int


func _ready() -> void:
	super()
	dead_exit_trigger.triggered.connect(_on_dead_exit_trigger_triggered)


func _on_dead_exit_trigger_triggered() -> void:
	if not player.state_machine.state.name in _state_names:
		return

	_previous_collision_layer = player.collision_layer
	player.collision_layer = 16  # Put player on invulnerable layer.
	$AnimationPlayer.play("flash")

	await get_tree().create_timer(duration).timeout

	player.collision_layer = _previous_collision_layer
	$AnimationPlayer.play("RESET")
