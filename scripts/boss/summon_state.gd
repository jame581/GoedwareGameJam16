extends LimboState

const SUMMON_DURATION: float = 2.0

var _elapsed: float = 0.0


func _enter() -> void:
	_elapsed = 0.0
	agent.velocity = Vector2.ZERO
	print("[ShockwaveBoss] Summoning shockwave...")


func _update(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= SUMMON_DURATION:
		get_root().dispatch(EVENT_FINISHED)
