extends Node

signal cutscene_ended
signal cutscene_started

const CAMERA_PATH = ^"%Camera2D"
const GHOST_GROUP = &"ghosts"
const PLAYER_GROUP = &"players"

@export var cutscene_in_progress := false:
	set = set_cutscene_in_progress

var _camera_enabled_states: Dictionary

@onready var grab: AudioStreamPlayer = $Grab
@onready var synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var timer: Timer = $Timer


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


func _on_cutscene_started() -> void:
	get_tree().paused = true
	_save_camera_enabled_states()
	_focus_cameras_ghost()
	grab.play()
	if not synchronizer.is_multiplayer_authority():
		return

	timer.start()


func _on_cutscene_ended() -> void:
	_restore_camera_enabled_states()
	get_tree().paused = false


func _focus_cameras_ghost() -> void:
	var ghost: Node = get_tree().get_first_node_in_group(GHOST_GROUP)
	if ghost == null:
		return

	var camera: Camera2D = ghost.get_node_or_null(CAMERA_PATH)
	if camera == null:
		return

	camera.enabled = true
	camera.make_current()


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
