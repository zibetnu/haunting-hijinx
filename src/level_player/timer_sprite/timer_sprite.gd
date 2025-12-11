class_name TimerSprite
extends Node2D

signal timeout

@export var textures: TimerSpriteTextures:
	set = set_textures
@export var wait_time: float = 1.0
@export var autostart: bool = false

var time_left: float:
	get = get_time_left

@onready var frame: Sprite2D = %Frame
@onready var minutes: Sprite2D = %Minutes
@onready var tens: Sprite2D = %Tens
@onready var ones: Sprite2D = %Ones
@onready var timer: Timer = $Timer


func _ready() -> void:
	_apply_textures()
	_update_frames()
	set_process(false)
	if autostart:
		start()


func _process(_delta: float) -> void:
	_update_frames()


func set_textures(value: TimerSpriteTextures) -> void:
	textures = value
	if is_node_ready():
		_apply_textures()


func start(time_sec: float = -1) -> void:
	if not is_node_ready():
		return

	timer.start(time_sec if time_sec > 0 else wait_time)
	set_process(true)


func stop() -> void:
	timer.stop()
	set_process(false)


func is_stopped() -> bool:
	if not is_node_ready():
		return true

	return timer.is_stopped()


func get_time_left() -> float:
	if not is_node_ready():
		return 0.0

	return timer.time_left


func _apply_textures() -> void:
	for sprite: Sprite2D in  [frame, ones, tens, ones]:
		sprite.texture = null
		sprite.offset = Vector2.ZERO

	if textures == null:
		return

	frame.texture = textures.frame_texture

	minutes.texture = textures.digits_texture
	minutes.offset = textures.digits_minute_offset

	tens.texture = textures.digits_texture
	tens.offset = textures.digits_tens_offset

	ones.texture = textures.digits_texture
	ones.offset = textures.digits_ones_offset


func _update_frames() -> void:
	const MINUTE = 60
	const TEN = 10
	minutes.frame = int(time_left / MINUTE) % TEN
	tens.frame = int(fposmod(time_left, MINUTE) / TEN)
	ones.frame = int(time_left) % TEN


func _on_timer_timeout() -> void:
	set_process(false)
	timeout.emit()
