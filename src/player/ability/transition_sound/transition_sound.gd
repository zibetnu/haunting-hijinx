extends Ability


@export var stream: AudioStream


func _ready() -> void:
	super()
	$AudioStreamPlayer2D.set_stream(stream)


func _on_player_state_machine_transitioned(state_name: String) -> void:
	if state_name in _state_names:
		$AudioStreamPlayer2D.play()
