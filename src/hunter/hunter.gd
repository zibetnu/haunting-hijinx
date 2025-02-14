extends ControllableCharacter

signal dropped

const GRABBED_EVENT = &"died"
const IS_MOVING = &"is_moving"

@export_group("State Collision", "state")
@export_flags_2d_physics var state_alive_layer: int
@export_flags_2d_physics var state_dead_layer: int
@export_flags_2d_physics var state_invulnerable_layer: int

@onready var flashlight: Flashlight = $Flashlight/Behavior
@onready var move: Move = $StateChart/Base/Alive/Movement/Move/Move
@onready var notification_container: HBoxContainer = %NotificationContainer
@onready var state_chart: StateChart = $StateChart


func _ready() -> void:
	state_chart.set_expression_property(IS_MOVING, false)


func enable_alive_collision_layer() -> void:
	collision_layer = state_alive_layer


func enable_dead_collision_layer() -> void:
	collision_layer = state_dead_layer


func enable_invulnerable_collision_layer() -> void:
	collision_layer = state_invulnerable_layer


func on_grabbed() -> void:
	notification_container.hide()
	state_chart.send_event(GRABBED_EVENT)


func on_dropped() -> void:
	notification_container.show()
	z_index = -1
	dropped.emit()


func _get_pairs() -> Array[Pair]:
	if controller == null:
		return []

	if not is_node_ready():
		return []

	var p := Pair
	var c: Controller = controller
	var event: Callable = state_chart.send_event
	var property: Callable = state_chart.set_expression_property
	return [
		p.new(c.button_1_changed, flashlight.set_powered),
		p.new(c.button_1_pressed, event.bind("button_1_pressed")),
		p.new(c.button_1_released, event.bind("button_1_released")),
		p.new(c.button_2_pressed, event.bind("button_2_pressed")),
		p.new(c.button_2_released, event.bind("button_2_released")),
		p.new(c.look_rotation_changed, flashlight.set_target_rotation),
		p.new(c.move_started, property.bind(IS_MOVING, true)),
		p.new(c.move_stopped, property.bind(IS_MOVING, false)),
		p.new(c.move_vector_changed, move.set_move_vector),
	]
