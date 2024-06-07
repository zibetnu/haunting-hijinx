extends Node


signal relay_initialized

const RELAY_WAIT_LOOP_SEC := 1.0

@export var initialize_on_ready := true

var _is_initialized := false

func _ready() -> void:
	Steam.relay_network_status.connect(_on_relay_network_status)
	if initialize_on_ready:
		initialize_relay()


# Steam.relay_network_status does not emit if the status changes because
# Steam.initRelayNetworkAccess was called. This is a workaround to allow
# waiting for the relay to be ready.
func initialize_relay() -> void:
	Steam.initRelayNetworkAccess()
	while Steam.getRelayNetworkStatus() != Steam.NETWORKING_AVAILABILITY_CURRENT:
		await get_tree().create_timer(RELAY_WAIT_LOOP_SEC).timeout

	if _is_initialized:
		return

	_emit_relay_initialized()


func _emit_relay_initialized() -> void:
	relay_initialized.emit()
	_is_initialized = true


func _on_relay_network_status(
		available: int,
		_ping_measurement: int,
		_available_config: int,
		_available_relay: int,
		_debug_message: String
) -> void:
	if available != Steam.NETWORKING_AVAILABILITY_CURRENT:
		return

	if _is_initialized:
		return

	_emit_relay_initialized()
