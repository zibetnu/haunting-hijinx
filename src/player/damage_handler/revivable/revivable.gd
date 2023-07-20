extends DamageHandler


@export var player: Player
@export var revived_state: State
@export var revives_with: DamageSource.Type
@export var max_progress := 600


var _progress := 0:
	set(value):
		_progress = clampi(value, 0, max_progress)


func _ready() -> void:
	player.died.connect(_on_player_died)


func handle_damage(source: DamageSource, affected_player: Player) -> void:
	if source.damage_type != revives_with:
		return

	_progress += source.damage_amount
	if _progress < max_progress:
		return

	_progress = 0
	if multiplayer.is_server():
		affected_player.health = affected_player.max_health
		affected_player.state_machine.transition_to.rpc(revived_state.name)
		player.revived.emit()


func _on_player_died() -> void:
	_progress = 0
