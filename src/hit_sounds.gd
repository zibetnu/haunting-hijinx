class_name HitSounds
extends AudioStreamPlayer2D

const STREAMS: Array[AudioStreamWAV] = [
	preload("uid://bm425cjpbjmji"),
	preload("uid://dpomybn654j64"),
	preload("uid://by7n6aejta2uk"),
	preload("uid://c0wmasatcxwyw"),
	preload("uid://cybnt4gfisxii"),
	preload("uid://de40soawm826b"),
	preload("uid://c7qun3vy4d1ac"),
	preload("uid://dyfvd7htlgb65"),
	preload("uid://djiwjk0s43u4l"),
	preload("uid://dlj2oc66utbfj"),
	preload("uid://clbx5u0wq2n5d"),
	preload("uid://cvu2ldu2kkvab"),
	preload("uid://c5bcgy1rfohrq"),
	preload("uid://cgvhdga5f2qpk"),
	preload("uid://cb2xnnyvje6ah"),
]

@export var enabled := false:
	set = set_enabled

@export var hits_per_second := 10

var stream_index := 0:
	set = set_stream_index

var _cooldown := 0
var _disable_timer := Timer.new()
@warning_ignore("integer_division")
var _max_cooldown: int = Engine.physics_ticks_per_second / hits_per_second
var _stream_playback: AudioStreamPlaybackPolyphonic


func _init() -> void:
	_disable_timer.one_shot = true
	_disable_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	_disable_timer.timeout.connect(set_enabled.bind(false))
	_disable_timer.wait_time = 1.0 / Engine.physics_ticks_per_second
	add_child(_disable_timer, false, Node.INTERNAL_MODE_FRONT)


func _enter_tree() -> void:
	var stream_polyphonic := AudioStreamPolyphonic.new()
	stream_polyphonic.polyphony = STREAMS.size() - 1
	stream = stream_polyphonic
	play()
	_stream_playback = get_stream_playback()


func _ready() -> void:
	set_physics_process(enabled)


func _physics_process(_delta: float) -> void:
	if _cooldown > 0:
		_cooldown -= 1
		return

	_cooldown = _max_cooldown
	_stream_playback.play_stream(STREAMS[stream_index])
	stream_index += 1


@rpc
func reset() -> void:
	enabled = false
	stream_index = 0
	_cooldown = 0
	if multiplayer.is_server():
		reset.rpc()


func set_enabled(value: bool) -> void:
	enabled = value
	set_physics_process(enabled)


func set_stream_index(value: int) -> void:
	stream_index = clamp(value, 0, STREAMS.size() - 1)


func start_disable_timer() -> void:
	_disable_timer.start()
