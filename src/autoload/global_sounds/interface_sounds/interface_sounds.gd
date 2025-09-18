class_name InterfaceSounds
extends Node

@onready var button_pressed: AudioStreamPlayer = $ButtonPressed
@onready var slider_changed: AudioStreamPlayer = $SliderChanged
@onready var signals_to_callables: Dictionary = {
	&"confirmed": button_pressed.play,
	&"item_activated": button_pressed.play,
	&"pressed": button_pressed.play,
	&"pressed_sound_requested": button_pressed.play,
	&"tab_selected": func (_tab: int) -> void: button_pressed.play(),
}


func _enter_tree() -> void:
	get_tree().node_added.connect(_on_node_added)


func play_for_slider(slider: Slider) -> void:
	slider_changed.pitch_scale = remap(
			slider.value,
			slider.min_value,
			slider.max_value,
			0.8,
			1.2
	)
	slider_changed.play()


func _on_node_added(node: Node) -> void:
	if node.owner == null:
		return

	if node.is_in_group(&"exclude_interface_sounds"):
		return

	if node is Slider:
		var slider: Slider = node
		slider.value_changed.connect(
				func (_value: float) -> void: play_for_slider(slider)
		)
		return

	for signal_name: StringName in signals_to_callables:
		if not node.has_signal(signal_name):
			continue

		var callable: Callable = signals_to_callables[signal_name]
		if node.is_connected(signal_name, callable):
			continue

		node.connect(signal_name, callable)
