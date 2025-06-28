extends ControllableCharacter

const IS_MOVING = &"is_moving"
const RESTART_DURING_PANIC_TIME = 1.33

var is_hidden_from_hunters := true:
	set = set_is_hidden_from_hunters

var is_panicked := false
var stunnable := true:
	set = set_stunnable

@onready var ghost_costume: GhostCostume = $GhostCostume
@onready var grab_area: Area2D = $Grab
@onready var grabber: Grabber = $Grab/Grabber
@onready var hit_sounds: HitSounds = %HitSounds
@onready var ignore_canvas_modulate: CanvasLayer = %IgnoreCanvasModulate
@onready var peer_id_node: PeerID = %PeerID
@onready var position_synchronizer: MultiplayerSynchronizer = $PositionSynchronizer
@onready var summon: Summon = %Summon
@onready var summon_bar: SummonBar = %SummonBar

@onready var end_timer: Timer = $StateChart/Base/Behavior/Alive/Panic/EndTimer
@onready var visible_timer: Timer = $StateChart/Base/Behavior/Alive/Panic/VisibleTimer

@onready var move_grab: Move = $StateChart/Base/Behavior/Alive/Grab/Move
@onready var move_normal: Move = $StateChart/Base/Behavior/Alive/Normal/Move
@onready var move_panic: Move = $StateChart/Base/Behavior/Alive/Panic/Move
@onready var move_sprint: Move = $StateChart/Base/Behavior/Alive/Sprint/Move
@onready var move_summon_release: Move = $StateChart/Base/Behavior/Alive/SummonRelease/Move

@onready var state_chart: StateChart = $StateChart
@onready var normal: AtomicState = $StateChart/Base/Behavior/Alive/Normal
@onready var sprint: AtomicState = $StateChart/Base/Behavior/Alive/Sprint


func _ready() -> void:
	position_synchronizer.add_visibility_filter(_visibility_filter)
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


@rpc("authority", "call_local", "reliable")
func set_is_hidden_from_hunters(value: bool) -> void:
	is_hidden_from_hunters = value
	modulate.a = 0.5 if is_hidden_from_hunters else 1.0
	if multiplayer.get_unique_id() != peer_id_node.id:
		visible = not is_hidden_from_hunters
		ignore_canvas_modulate.visible = visible


func set_stunnable(value: bool) -> void:
	stunnable = value


@rpc("authority", "call_remote", "reliable")
func sync_and_unhide(new_position: Vector2) -> void:
	position = new_position
	is_hidden_from_hunters = false


func _on_damage_taken() -> void:
	if stunnable:
		state_chart.send_event(&"stunned")


func _on_grab_state_physics_processing(_delta: float) -> void:
	grab_area.rotation = ghost_costume.costume_rotation


func _on_hunters_touched_first_node_entered() -> void:
	if not is_panicked:
		return

	end_timer.paused = true
	visible_timer.paused = true
	state_chart.send_event(&"invisibility_ended")


func _on_grabber_grabbed_target(from_global_position: Vector2) -> void:
	var angle: float = global_position.angle_to_point(from_global_position)
	grab_area.rotation = angle
	ghost_costume.set_costume_rotation(angle)
	state_chart.send_event(&"grab_started")


func _on_hunters_touched_last_node_exited() -> void:
	if not is_panicked:
		return

	end_timer.start(RESTART_DURING_PANIC_TIME)
	end_timer.paused = false
	visible_timer.start()
	visible_timer.paused = false


func _on_invisibile_state_entered() -> void:
	if not multiplayer.is_server():
		return

	set_is_hidden_from_hunters.rpc(true)


func _on_panic_event_received(event: StringName) -> void:
	if event != &"damaged":
		return

	if end_timer.time_left < RESTART_DURING_PANIC_TIME:
		end_timer.start(RESTART_DURING_PANIC_TIME)

	visible_timer.start()
	hit_sounds.enabled = true
	hit_sounds.start_disable_timer()


func _on_panic_state_entered() -> void:
	is_panicked = true
	end_timer.start()
	end_timer.paused = false
	visible_timer.start()
	visible_timer.paused = false


func _on_panic_state_exited() -> void:
	is_panicked = false
	end_timer.stop()
	visible_timer.stop()
	hit_sounds.reset()


func _on_summon_area_count_changed(area_count: int) -> void:
	state_chart.set_expression_property(&"drain_areas", area_count)


func _on_summon_charged() -> void:
	state_chart.send_event(&"summon_charged")


func _on_summon_started() -> void:
	state_chart.send_event(&"summon_charging")
	summon_bar.start(summon.charge_time)


func _on_summon_stopped() -> void:
	summon_bar.stop()


func _on_visibile_state_entered() -> void:
	is_hidden_from_hunters = false
	if not multiplayer.is_server():
		return

	sync_and_unhide.rpc(position)


func _visibility_filter(peer_id: int) -> bool:
	return (not is_hidden_from_hunters) or peer_id == peer_id_node.id
