extends LimboState

var _elapsed: float = 0.0


func _enter() -> void:
	_elapsed = 0.0
	blackboard.set_var("was_hit", false)
	agent.is_grounded = true
	agent.set_exposed(true)
	agent.spawn_shockwaves()
	print("[ShockwaveBoss] Landed! Exposed for 2s.")


func _exit() -> void:
	agent.set_exposed(false)
	agent.is_grounded = false # Fly back up


func _update(delta: float) -> void:
	_elapsed += delta

	# Check for timeout
	if _elapsed >= agent.shockwave_exposed_duration:
		get_root().dispatch(EVENT_FINISHED)
		return

	# Check if boss was hit (via blackboard or signal)
	if blackboard.get_var("was_hit", false):
		blackboard.set_var("was_hit", false)
		get_root().dispatch(EVENT_FINISHED)
