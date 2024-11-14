extends Node2D

const MAX_BATTERY_SPAWN_ATTEMPTS = 100

@export var battery_scene: PackedScene
@export var spawn_area_top_left: Node2D
@export var spawn_area_bottom_right: Node2D
@export var spawn_root: Node2D

var _batteries_spawned := 0

@onready var _position_checker := $PositionChecker


func _get_random_battery_position() -> Vector2:
	return Vector2(
			randf_range(
					spawn_area_top_left.position.x,
					spawn_area_bottom_right.position.x
			),
			randf_range(
					spawn_area_top_left.position.y,
					spawn_area_bottom_right.position.y
			)
	)


func _is_position_clear(check_position: Vector2) -> bool:
	_position_checker.position = check_position
	_position_checker.force_shapecast_update()
	return not _position_checker.is_colliding()


func _on_timer_timeout() -> void:
	if not multiplayer.is_server():
		return

	var batteries_needed = 0
	for flashlight in get_tree().get_nodes_in_group("flashlights"):
		if not flashlight.get("enabled"):
			continue

		if not flashlight.get("is_battery_low"):
			continue

		batteries_needed += 1

	if _batteries_spawned >= batteries_needed:
		return

	var instance = battery_scene.instantiate()
	var instance_position := _get_random_battery_position()
	var i := 0
	while (
			i < MAX_BATTERY_SPAWN_ATTEMPTS
			and not _is_position_clear(instance_position)
	):
		instance_position = _get_random_battery_position()
		i += 1

	if not (i < MAX_BATTERY_SPAWN_ATTEMPTS):
		push_error("Could not find valid battery spawn point.")
		instance.queue_free()
		return

	instance.position = instance_position
	instance.tree_exited.connect(_on_battery_tree_exited)
	spawn_root.add_child(instance, true)
	_batteries_spawned += 1


func _on_battery_tree_exited() -> void:
	_batteries_spawned -= 1
