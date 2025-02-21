class_name Grabber
extends Node2D

signal grabbed_target(from_global_position: Vector2)
signal dropped_target

const GRABBED_METHOD = &"on_grabbed"
const DROPPED_METHOD = &"on_dropped"

@onready var remote_transform_2d: RemoteTransform2D = $RemoteTransform2D


func grab(target: Node2D) -> void:
	var prior_target: Node = get_node_or_null(remote_transform_2d.remote_path)
	if target == prior_target:
		return

	if prior_target != null:
		drop()

	var grabbed_from: Vector2 = target.global_position
	remote_transform_2d.remote_path = target.get_path()
	if target.has_method(GRABBED_METHOD):
		target.call(GRABBED_METHOD)

	grabbed_target.emit(grabbed_from)


func drop() -> void:
	var target: Node = get_node_or_null(remote_transform_2d.remote_path)
	if target == null:
		return

	remote_transform_2d.remote_path = NodePath()
	if target.has_method(DROPPED_METHOD):
		target.call(DROPPED_METHOD)

	dropped_target.emit()
