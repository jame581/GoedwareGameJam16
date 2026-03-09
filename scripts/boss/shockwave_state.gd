extends LimboState

const WAIT_DURATION: float = 0.5

var _elapsed: float = 0.0


func _enter() -> void:
	_elapsed = 0.0
	agent.velocity = Vector2.ZERO
	agent.spawn_shockwaves()
	print("[ShockwaveBoss] Shockwave spawned! Impact finished.")


func _update(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= WAIT_DURATION:
		get_root().dispatch(EVENT_FINISHED)
