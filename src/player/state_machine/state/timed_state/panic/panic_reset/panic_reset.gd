extends Panic


func handle_damage(source: DamageSource) -> void:
	super(source)
	timer.stop()
	timer.start(state_time)
