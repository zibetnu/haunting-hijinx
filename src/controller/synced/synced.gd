class_name SyncedController
extends Controller


@export var local_controller: Controller
@export var peer_id := 1:
	set(value):
		peer_id = value
		set_multiplayer_authority(value)
		if _is_ready:
			set_process(_should_process())

var _is_ready := false


func _ready() -> void:
	set_process(_should_process())
	# Only the server needs to know about the server player's input.
	if multiplayer.is_server():
		$MultiplayerSynchronizer.public_visibility = false

	_is_ready = true


func _process(_delta: float) -> void:
	move_vector = local_controller.move_vector
	look_vector = local_controller.look_vector
	button_1_pressed = local_controller.button_1_pressed
	button_2_pressed = local_controller.button_2_pressed


func _should_process() -> bool:
	return get_multiplayer_authority() == multiplayer.get_unique_id()
