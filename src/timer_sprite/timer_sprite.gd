extends Node2D


const MINUTE = 60
const TEN = 10

@export var timer: Timer

@onready var minute_ones: Sprite2D = $MinuteOnes
@onready var second_tens: Sprite2D = $SecondTens
@onready var second_ones: Sprite2D = $SecondOnes


func _process(_delta: float) -> void:
	if timer == null:
		return

	if timer.is_stopped():
		return

	var time_left := timer.time_left
	minute_ones.frame = int(time_left / MINUTE) % TEN
	second_tens.frame = int(fmod(time_left, MINUTE) / TEN)
	second_ones.frame = int(time_left) % TEN
