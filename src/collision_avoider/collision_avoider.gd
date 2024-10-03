extends Node2D


@export var target: Node2D

@export_group("Collision", "collision")
@export var collision_shape: Shape2D:
	set = set_collision_shape
@export_flags_2d_physics var collision_mask := 1:
	set = set_collision_mask

@export_group("Search", "search")
@export var search_position_step := 1.0
@export var search_rotation_increments := 8

@export_group("Move Interpolation", "interpolation")
@export var interpolation_enabled := true
@export var interpolation_speed := 6.0

var _interpolate_to: Vector2

@onready var shape_cast: ShapeCast2D = $ShapeCast2D


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	target.global_position = target.global_position.lerp(
			_interpolate_to,
			delta * interpolation_speed
	)
	if target.global_position.is_equal_approx(_interpolate_to):
		set_physics_process(false)


func get_non_colliding_global_position() -> Vector2:
	rotation = -TAU / search_rotation_increments
	shape_cast.position.x = 0
	shape_cast.force_shapecast_update()

	var i := 0
	while shape_cast.is_colliding():
		if i % search_rotation_increments == 0:
			shape_cast.position.x += search_position_step

		rotation += TAU / search_rotation_increments
		i += 1
		shape_cast.force_shapecast_update()

	return shape_cast.global_position


## Moves [member target] to a nearby position with no detected collisions.
func move_target() -> void:
	if interpolation_enabled:
		_interpolate_to = get_non_colliding_global_position()
		set_physics_process(true)

	else:
		target.global_position = get_non_colliding_global_position()


func set_collision_mask(value: int) -> void:
	collision_mask = value
	if not is_node_ready():
		await ready

	shape_cast.collision_mask = collision_mask


func set_collision_shape(value: Shape2D) -> void:
	collision_shape = value
	if not is_node_ready():
		await ready

	shape_cast.shape = collision_shape
