extends State


@export var exit_state: State
@export var player_touched: PlayerTouched
@export var speed_multiplier := 1.66

var _taking_damage := false:
	set(value):
		_taking_damage = value
		_check_transition_conditions()

@onready var damage_timer: Timer = $DamageTimer


func _ready() -> void:
	player_touched.touched_player_count_changed.connect(_on_touched_player_count_changed)


func handle_damage(source: DamageSource) -> void:
	super(source)
	_taking_damage = true
	damage_timer.start()


func physics_update(_delta: float) -> void:
	player.velocity = player.controller.move_vector * player.move_speed * speed_multiplier
	player.sync_move_and_slide()


func _check_transition_conditions() -> void:
	if not multiplayer.is_server():
		return

	if _taking_damage:
		return

	if player_touched.touched_players.size() > 0:
		return

	state_machine.transition_to.rpc(exit_state.name, {"state_time": 1.3333, "use_remaining": true})


func _on_damage_timer_timeout() -> void:
	_taking_damage = false


func _on_touched_player_count_changed() -> void:
	_check_transition_conditions()
