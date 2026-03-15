@tool
extends BTAction
## GlowTelegraph: Tint sprite bright as a telegraph, wait glow_duration seconds.

@export var glow_duration_var: StringName = &"glow_duration"

var _timer: float = 0.0
var _duration: float = 0.0

func _generate_name() -> String:
	return "GlowTelegraph (%s)" % [LimboUtility.decorate_var(glow_duration_var)]

func _enter() -> void:
	_duration = blackboard.get_var(glow_duration_var, 0.8)
	_timer = 0.0
	agent.get_node("Sprite2D").modulate = Color(2.0, 1.5, 0.5)
	agent.play_animation("charge")

func _tick(delta: float) -> Status:
	_timer += delta
	if _timer >= _duration:
		return SUCCESS
	return RUNNING

func _exit() -> void:
	if is_instance_valid(agent):
		agent.get_node("Sprite2D").modulate = Color.WHITE
