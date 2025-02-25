extends ControllableCharacter

const IS_MOVING = &"is_moving"

@onready var ghost_costume: GhostCostume = $GhostCostume

@onready var grab_area: Area2D = $Grab
@onready var grabber: Grabber = $Grab/Grabber

@onready var move_grab: Move = $StateChart/Base/Behavior/Alive/Grab/Move
@onready var move_normal: Move = $StateChart/Base/Behavior/Alive/Normal/Move
@onready var move_panic: Move = $StateChart/Base/Behavior/Alive/Panic/Move
@onready var move_sprint: Move = $StateChart/Base/Behavior/Alive/Sprint/Move
@onready var move_summon_release: Move = $StateChart/Base/Behavior/Alive/SummonRelease/Move

@onready var state_chart: StateChart = $StateChart
@onready var normal: AtomicState = $StateChart/Base/Behavior/Alive/Normal
@onready var sprint: AtomicState = $StateChart/Base/Behavior/Alive/Sprint


func _ready() -> void:
	state_chart.set_expression_property(IS_MOVING, false)


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
		p.new(c.button_1_pressed, event.bind("button_1_pressed")),
		p.new(c.button_1_released, event.bind("button_1_released")),
		p.new(c.button_2_pressed, event.bind("button_2_pressed")),
		p.new(c.button_2_released, event.bind("button_2_released")),
		p.new(c.move_rotation_changed, grab_area.set_rotation),
		p.new(c.move_rotation_changed, ghost_costume.set_costume_rotation),
		p.new(c.move_started, event.bind("move_started")),
		p.new(c.move_started, property.bind(IS_MOVING, true)),
		p.new(c.move_stopped, event.bind("move_stopped")),
		p.new(c.move_stopped, property.bind(IS_MOVING, false)),
		p.new(c.move_vector_changed, move_grab.set_move_vector),
		p.new(c.move_vector_changed, move_panic.set_move_vector),
		p.new(c.move_vector_changed, move_normal.set_move_vector),
		p.new(c.move_vector_changed, move_sprint.set_move_vector),
		p.new(c.move_vector_changed, move_summon_release.set_move_vector),
		p.new(normal.state_entered, c.force_emit_button_1_signals),
		p.new(normal.state_entered, c.force_emit_button_2_signals),
		p.new(normal.state_entered, c.force_emit_move_vector_signals),
		p.new(sprint.state_entered, c.force_emit_move_vector_signals),
	]
