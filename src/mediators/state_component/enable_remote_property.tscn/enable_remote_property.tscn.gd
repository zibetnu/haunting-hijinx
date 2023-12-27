extends StateComponent


@export var remote_property: RemoteProperty
@export var process_callback := RemoteProperty.ProcessCallback.IDLE


func _on_state_entered() -> void:
	remote_property.process_callback = process_callback


func _on_state_exited() -> void:
	remote_property.process_callback = RemoteProperty.ProcessCallback.NONE
