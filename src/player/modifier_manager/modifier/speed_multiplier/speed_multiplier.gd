extends Modifier


@export var multiplier := 1.0

var _old_move_speed: int


func modify(player: Player) -> void:
	if _modified_player:
		return

	_old_move_speed = player.move_speed
	@warning_ignore("narrowing_conversion")
	player.move_speed *= multiplier
	_modified_player = player


func unmodify() -> void:
	if not _modified_player:
		return

	_modified_player.move_speed = _old_move_speed
	_modified_player = null
