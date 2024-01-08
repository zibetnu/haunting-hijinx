class_name PeerID
extends Node


signal changed(id: int)

@export var id := 1:
	set(value):
		if id != value:
			id = value
			changed.emit(id)
