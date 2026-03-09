extends LimboState

const SUMMON_DURATION: float = 1.2

var _elapsed: float = 0.0


func _enter() -> void:
	_elapsed = 0.0
	agent.velocity = Vector2.ZERO
	print("[ShockwaveBoss] Summoning shockwave (mid-air)...")


func _update(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= SUMMON_DURATION:
		get_root().dispatch(EVENT_FINISHED)
