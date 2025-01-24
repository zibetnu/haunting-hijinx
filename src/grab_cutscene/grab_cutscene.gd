extends Node

signal cutscene_ended
signal cutscene_started

const CAMERA_PATH = ^"%Camera2D"
const GHOST_GROUP = &"ghosts"
const PLAYER_GROUP = &"players"

const CUTSCENE_TIME = 2.0
const ZOOM_TIME = 0.3
const HOLD_TIME = 1.4
const FADE_TIME = 0.3

const ZOOM_START = Vector2.ONE
const ZOOM_END = Vector2.ONE * 2

const SPOTLIGHT_SIZE_PROPERTY = ^"spotlight_size"
const SPOTLIGHT_SIZE_START = 1.1
const SPOTLIGHT_SIZE_END = 0.25

const MODULATE_PROPERTY = ^"modulate:a"
const MODULATE_START = 0.0
const MODULATE_END = 1.0

@export var cutscene_in_progress := false:
	set = set_cutscene_in_progress

var _camera_enabled_states: Dictionary

@onready var grab: AudioStreamPlayer = $Grab
@onready var spotlight: Spotlight = %Spotlight
@onready var synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var timer: Timer = $Timer
@onready var transition: ColorRect = %Transition


func _ready() -> void:
	cutscene_started.connect(_on_cutscene_started)
	cutscene_ended.connect(_on_cutscene_ended)


func set_cutscene_in_progress(value: bool) -> void:
	var prior_value: bool = cutscene_in_progress
	cutscene_in_progress = value
	match [prior_value, value]:
		[false, true]:
			cutscene_started.emit()

		[true, false]:
			cutscene_ended.emit()


func start_cutscene() -> void:
	cutscene_in_progress = true


func end_cutscene() -> void:
	cutscene_in_progress = false


func _create_tween() -> Tween:
	var tween: Tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_trans(Tween.TRANS_CUBIC)
	return tween


func _tween_restore_cameras() -> void:
	transition.modulate.a = MODULATE_START
	var tween: Tween = _create_tween()
	tween.tween_interval(CUTSCENE_TIME - FADE_TIME * 2)
	tween.tween_callback(transition.show)
	tween.tween_property(
			transition,
			MODULATE_PROPERTY,
			MODULATE_END,
			FADE_TIME
	)
	tween.tween_callback(_restore_camera_enabled_states)
	tween.tween_property(
			transition,
			MODULATE_PROPERTY,
			MODULATE_START,
			FADE_TIME
	)
	tween.tween_callback(transition.hide)



func _tween_spotlight(camera: CenteredCamera) -> void:
	spotlight.focus_on = camera
	spotlight.spotlight_size = SPOTLIGHT_SIZE_START
	spotlight.show()
	var tween: Tween = _create_tween()
	tween.tween_property(
			spotlight,
			SPOTLIGHT_SIZE_PROPERTY,
			SPOTLIGHT_SIZE_END,
			ZOOM_TIME
	)
	tween.tween_interval(HOLD_TIME)
	tween.tween_property(
			spotlight,
			SPOTLIGHT_SIZE_PROPERTY,
			SPOTLIGHT_SIZE_START,
			ZOOM_TIME
	)
	tween.tween_callback(spotlight.hide)


func _tween_zoom(camera: CenteredCamera) -> void:
	var tween: Tween = _create_tween()
	tween.tween_method(
			camera.set_zoom_centered,
			ZOOM_START,
			ZOOM_END,
			ZOOM_TIME
	)
	tween.tween_interval(HOLD_TIME)
	tween.tween_method(
			camera.set_zoom_centered,
			ZOOM_END,
			ZOOM_START,
			ZOOM_TIME
	)


func _on_cutscene_started() -> void:
	get_tree().paused = true
	_save_camera_enabled_states()
	_focus_cameras_ghost()
	_tween_restore_cameras()
	grab.play()
	if not synchronizer.is_multiplayer_authority():
		return

	timer.start(CUTSCENE_TIME)


func _on_cutscene_ended() -> void:
	get_tree().paused = false


func _focus_cameras_ghost() -> void:
	var ghost: Node = get_tree().get_first_node_in_group(GHOST_GROUP)
	if ghost == null:
		return

	var camera: CenteredCamera = ghost.get_node_or_null(CAMERA_PATH)
	if camera == null:
		return

	camera.enabled = true
	camera.make_current()
	_tween_spotlight(camera)
	_tween_zoom(camera)


func _restore_camera_enabled_states() -> void:
	for player in get_tree().get_nodes_in_group(PLAYER_GROUP):
		var camera: Camera2D = player.get_node_or_null(CAMERA_PATH)
		if camera == null:
			continue

		var key: NodePath = camera.get_path()
		if not _camera_enabled_states.has(key):
			continue

		camera.enabled = _camera_enabled_states[key]


func _save_camera_enabled_states() -> void:
	for player in get_tree().get_nodes_in_group(PLAYER_GROUP):
		var camera: Camera2D = player.get_node_or_null(CAMERA_PATH)
		if camera == null:
			continue

		_camera_enabled_states[camera.get_path()] = camera.enabled
