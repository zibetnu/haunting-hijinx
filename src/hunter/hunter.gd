class_name Hunter
extends ControllableCharacter

signal dropped

const GRABBED_EVENT = &"died"

@export var move_speed: float = 74.0
@export var slowed_move_speed: float = 29.6

@export_group("Alive Collision", "alive")
@export_flags_2d_physics var alive_layer: int
@export_flags_2d_physics var alive_mask: int

@export_group("Dead Collision", "dead")
@export_flags_2d_physics var dead_layer: int
@export_flags_2d_physics var dead_mask: int

@export_group("Invulnerable Collision", "invulnerable")
@export_flags_2d_physics var invulnerable_layer: int
@export_flags_2d_physics var invulnerable_mask: int

@onready var costume: HunterCostume = $HunterCostume
@onready var flashlight: Flashlight = $Flashlight/Behavior
@onready var notification_container: HBoxContainer = %NotificationContainer
@onready var peer_id_node: PeerID = %PeerID
@onready var state_chart: StateChart = $StateChart
@onready var move_state: AtomicState = $StateChart/Base/Alive/Movement/Move
@onready var conveyor_cast: ShapeCast2D = $ConveyorCast


func _ready() -> void:
	if not multiplayer.is_server():
		set_physics_process(false)


func _physics_process(_delta: float) -> void:
	velocity = _get_conveyor_belt_velocity()
	if move_state.active:
		velocity += controller.move_vector * (
				slowed_move_speed if flashlight.powered else move_speed
		)

	move_and_slide()


func enable_alive_collision() -> void:
	collision_layer = alive_layer
	collision_mask = alive_mask


func enable_dead_collision() -> void:
	collision_layer = dead_layer
	collision_mask = dead_mask


func enable_invulnerable_collision() -> void:
	collision_layer = invulnerable_layer
	collision_mask = invulnerable_mask


func on_grabbed() -> void:
	notification_container.hide()
	state_chart.send_event(GRABBED_EVENT)


func on_dropped() -> void:
	notification_container.show()
	z_index = -1
	dropped.emit()


func _get_conveyor_belt_velocity() -> Vector2:
	if not conveyor_cast.is_colliding():
		return Vector2.ZERO

	var layer := conveyor_cast.get_collider(0) as TileMapLayer
	if layer == null:
		return Vector2.ZERO

	var coords: Vector2i = layer.local_to_map(layer.to_local(global_position))
	var tile_data: TileData = layer.get_cell_tile_data(coords)
	if tile_data == null:
		return Vector2.ZERO

	const DATA_LAYER_NAME = "linear_velocity"
	if not tile_data.has_custom_data(DATA_LAYER_NAME):
		return Vector2.ZERO

	return tile_data.get_custom_data(DATA_LAYER_NAME)


func _get_pairs() -> Array[Pair]:
	if controller == null:
		return []

	if not is_node_ready():
		return []

	var p := Pair
	var c: Controller = controller
	var property: Callable = state_chart.set_expression_property
	const IS_MOVING = &"is_moving"
	return [
		p.new(c.button_1_changed, flashlight.set_powered),
		p.new(c.look_rotation_changed, flashlight.set_target_rotation),
		p.new(c.move_started, property.bind(IS_MOVING, true)),
		p.new(c.move_stopped, property.bind(IS_MOVING, false)),
	]
