class_name Battery
extends Node2D

signal acquired
signal destroyed

const ACQUIRER_PROPERTY = &"battery_percentage"
const ACQUIRER_VALUE = 1.0

@onready var area: Area2D = $Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	if multiplayer.is_server():
		area.area_entered.connect(acquire)
		area.body_entered.connect(acquire)

	spawn()


func spawn() -> void:
	animation_player.play(&"spawn")
	await animation_player.animation_finished
	animation_player.play(&"bob")


func acquire(acquirer: Object) -> void:
	if not ACQUIRER_PROPERTY in acquirer:
		return

	acquirer.set(ACQUIRER_PROPERTY, ACQUIRER_VALUE)
	acquired.emit()
	queue_free()


@rpc("authority", "call_remote", "reliable")
func destroy() -> void:
	if multiplayer.is_server():
		destroy.rpc()

	animation_player.play(&"destroy")
	await animation_player.animation_finished
	destroyed.emit()
	queue_free()
