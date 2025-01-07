extends Node2D

signal camera_limits_applied

@export var quests: Array[Quest] = []
@export var play_complete_sound: Array[Quest] = []
@export var battery_quest: Quest

var auto_recharge := false:
	set = set_auto_recharge
var current_quest: Quest = null:
	set = set_current_quest

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var flashlights: Array[FlashlightBehavior] = []
@onready var ghost: CharacterBody2D = %Ghost
@onready var hunter: CharacterBody2D = %Hunter
@onready var limit_top_left: Marker2D = $LimitTopLeft
@onready var limit_bottom_right: Marker2D = $LimitBottomRight
@onready var npc_hunter: CharacterBody2D = $NPCHunter
@onready var objective: RichTextLabel = %Objective


func _ready() -> void:
	flashlights.assign(get_tree().get_nodes_in_group("flashlights"))
	_apply_camera_limits(ghost)
	_apply_camera_limits(hunter)
	for quest in quests:  # TODO: add explanation.
		quest.is_started = false
		quest.is_completed = false

	for quest in play_complete_sound:
		quest.completed.connect(audio_stream_player.play)

	for flashlight in flashlights:
		flashlight.battery_died.connect(
				_on_flashlight_battery_died.bind(flashlight)
		)

	var ghost_peer_id: PeerID = ghost.get_node_or_null(^"%PeerID")
	if ghost_peer_id != null:
		ghost_peer_id.id = -1

	var npc_hunter_peer_id: PeerID = npc_hunter.get_node_or_null(^"%PeerID")
	if npc_hunter_peer_id != null:
		npc_hunter_peer_id.id = -1

	var ghost_name_label: Label = ghost.get_node_or_null(^"%NameLabel")
	if ghost_name_label != null:
		ghost_name_label.hide()

	var npc_hunter_name_label: Label = npc_hunter.get_node_or_null(^"%NameLabel")
	if npc_hunter_name_label != null:
		npc_hunter_name_label.hide()


	_on_current_quest_completed()


func recharge(flashlight: FlashlightBehavior) -> void:
	flashlight.battery_percentage = 1.0


func recharge_all() -> void:
	for flashlight in flashlights:
		recharge(flashlight)


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

	objective.text = "[center]%s[/center]" % current_quest.objective
	current_quest.completed.connect(_on_current_quest_completed)


func revive(player: Node) -> void:
	var state_chart: StateChart = player.get_node("%StateChart")
	state_chart.send_event(&"revived")


func revive_ghost() -> void:
	var ghost_health: Health = ghost.get_node_or_null("%Health")
	if ghost_health == null:
		return

	ghost_health.health = ghost_health.max_health


func revive_hunter() -> void:
	var state_chart: StateChart = hunter.get_node("%StateChart")
	state_chart.send_event(&"revived")


func _apply_camera_limits(camera_parent: Node) -> void:
	var camera: Camera2D = camera_parent.get_node_or_null(^"%Camera2D")
	if camera == null:
		return

	camera.limit_left = roundi(limit_top_left.position.x)
	camera.limit_right = roundi(limit_bottom_right.position.x)
	camera.limit_top = roundi(limit_top_left.position.y)
	camera.limit_bottom = roundi(limit_bottom_right.position.y)
	camera_limits_applied.emit()


func _on_current_quest_completed() -> void:
	if quests.is_empty():
		return

	animation_player.play("new_animation")
	await animation_player.animation_finished
	current_quest = quests.pop_front()
	animation_player.play_backwards("new_animation")
	await animation_player.animation_finished
	current_quest.start()


func _on_exit_prompt_pressed() -> void:
	SceneChanger.change_to_main_menu()


func _on_flashlight_battery_died(flashlight: FlashlightBehavior) -> void:
	if not auto_recharge:
		return

	recharge(flashlight)


func _on_skip_prompt_pressed() -> void:
	if current_quest == null:
		return

	current_quest.complete()


func _on_battery_spawned(battery: Battery) -> void:
	battery.acquired.connect(battery_quest.complete)
