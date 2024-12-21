extends Node2D

const MAX_ATTEMPT_COUNT = 10
const POINT_DOWN_NAME = "point_down"
const POINT_UP_NAME = "point_up"
const FADE_NAME = "fade"
const RESET_NAME = "RESET"

var _attempt_count := 0

@onready var top_notifier: VisibleOnScreenNotifier2D = $TopNotifier
@onready var bottom_notifier: VisibleOnScreenNotifier2D = $BottomNotifier
@onready var player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer


func _ready() -> void:
	set_process(false)


func _process(_delta: float) -> void:
	if _attempt_count >= MAX_ATTEMPT_COUNT:
		stop()
		return

	_attempt_count += 1
	var top_is_on_screen: bool = top_notifier.is_on_screen()
	if not (top_is_on_screen or bottom_notifier.is_on_screen()):
		return

	player.play(POINT_DOWN_NAME if top_is_on_screen else POINT_UP_NAME)
	timer.start()
	set_process(false)


func point() -> void:
	_attempt_count = 0
	set_process(true)


func stop() -> void:
	set_process(false)
	_attempt_count = 0
	if not is_node_ready():
		return

	timer.stop()
	player.play(RESET_NAME)


func _on_timer_timeout() -> void:
	player.play(FADE_NAME)
