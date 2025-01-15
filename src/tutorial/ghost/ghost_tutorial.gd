extends Tutorial

const ALERT_PATH = ^"%Alert"

@export var low_alert_quest: Quest
@export var high_alert_quest: Quest


func _ready() -> void:
	super()
	make_npc(hunter)
	var hunter_alert: Alert = hunter.get_node_or_null(ALERT_PATH)
	if hunter_alert != null:
		hunter_alert.alerted_low.connect(low_alert_quest.complete)
		hunter_alert.alerted_high.connect(high_alert_quest.complete)


# Workaround for the editor bizarrely refusing to connect signals to this
# method from the parent class.
func set_auto_recharge(value: bool) -> void:
	super(value)
