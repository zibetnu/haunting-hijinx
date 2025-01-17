class_name Tutorial
extends Node2D

signal camera_limits_applied

const FADE_ANIMATION = &"fade"
const FLASHLIGHT_GROUP = &"flashlights"
const NPC_PEER_ID = -1
const OBJECTIVE_FORMAT_STRING = "[center]%s[/center]"
const RECHARGE_PERCENTAGE = 1.0
const REVIVED_EVENT = &"revived"

const CAMERA_PATH = ^"%Camera2D"
const HEALTH_PATH = ^"%Health"
const NAME_PATH = ^"%NameLabel"
const PEER_ID_PATH = ^"%PeerID"
const STATE_CHART_PATH = ^"%StateChart"

@export var quests: Array[Quest] = []
@export var play_complete_sound: Array[Quest] = []

var auto_recharge := false:
	set = set_auto_recharge
var current_quest: Quest = null:
	set = set_current_quest

# For some reason, the exported quests array persists even after the tutorial
# scene is freed. _quests is initialized as a copy so quests can be popped
# from it without affecting the original.
var _quests: Array[Quest] = []

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var flashlights: Array[Flashlight] = []
@onready var ghost: CharacterBody2D = %Ghost
@onready var hunter: CharacterBody2D = %Hunter
@onready var limit_top_left: Marker2D = %LimitTopLeft
@onready var limit_bottom_right: Marker2D = %LimitBottomRight
@onready var objective: RichTextLabel = %Objective


func _ready() -> void:
	_apply_camera_limits(ghost)
	_apply_camera_limits(hunter)

	# Manually resets quests because for some reason changes to the quest
	# resources persist even after the tutorial scene was freed.
	for quest in quests:
		quest.is_started = false
		quest.is_completed = false

	_quests.assign(quests)
	for quest in play_complete_sound:
		quest.completed.connect(audio_stream_player.play)

	flashlights.assign(get_tree().get_nodes_in_group(FLASHLIGHT_GROUP))
	for flashlight in flashlights:
		flashlight.battery_died.connect(
				_on_flashlight_battery_died.bind(flashlight)
		)

	_on_current_quest_completed()


func make_npc(character: Node) -> void:
	var peer_id: PeerID = character.get_node_or_null(PEER_ID_PATH)
	if peer_id != null:
		peer_id.id = NPC_PEER_ID

	var name_label: Label = character.get_node_or_null(NAME_PATH)
	if name_label != null:
		name_label.hide()


func recharge(flashlight: Flashlight) -> void:
	flashlight.battery_percentage = RECHARGE_PERCENTAGE


func recharge_all() -> void:
	for flashlight in flashlights:
		recharge(flashlight)


func revive(player: Node) -> void:
	var state_chart: StateChart = player.get_node(STATE_CHART_PATH)
	state_chart.send_event(REVIVED_EVENT)


func revive_ghost() -> void:
	var ghost_health: Health = ghost.get_node_or_null(HEALTH_PATH)
	if ghost_health == null:
		return

	ghost_health.health = ghost_health.max_health


func revive_hunter() -> void:
	var state_chart: StateChart = hunter.get_node(STATE_CHART_PATH)
	state_chart.send_event(REVIVED_EVENT)


func set_auto_recharge(value: bool) -> void:
	auto_recharge = value
	if not auto_recharge:
		return

	recharge_all()


func set_current_quest(value: Quest) -> void:
	if current_quest != null:
		current_quest.completed.disconnect(_on_current_quest_completed)

	current_quest = value
	if current_quest == null:
		return

	objective.text = OBJECTIVE_FORMAT_STRING % current_quest.objective
	current_quest.completed.connect(_on_current_quest_completed)


func _apply_camera_limits(camera_parent: Node) -> void:
	var camera: Camera2D = camera_parent.get_node_or_null(CAMERA_PATH)
	if camera == null:
		return

	camera.limit_left = roundi(limit_top_left.position.x)
	camera.limit_right = roundi(limit_bottom_right.position.x)
	camera.limit_top = roundi(limit_top_left.position.y)
	camera.limit_bottom = roundi(limit_bottom_right.position.y)
	camera_limits_applied.emit()


func _on_current_quest_completed() -> void:
	if _quests.is_empty():
		return

	animation_player.play(FADE_ANIMATION)
	await animation_player.animation_finished
	current_quest = _quests.pop_front()
	animation_player.play_backwards(FADE_ANIMATION)
	await animation_player.animation_finished
	current_quest.start()


func _on_exit_prompt_pressed() -> void:
	SceneChanger.change_to_main_menu()


func _on_flashlight_battery_died(flashlight: Flashlight) -> void:
	if not auto_recharge:
		return

	recharge(flashlight)


func _on_skip_prompt_pressed() -> void:
	if current_quest == null:
		return

	current_quest.complete()
