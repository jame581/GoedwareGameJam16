@tool
extends BTAction
## VulnerableWindow: Set agent as exposed for vulnerable_duration seconds.

@export var vulnerable_duration_var: StringName = &"vulnerable_duration"

var _timer: float = 0.0
var _duration: float = 0.0

func _generate_name() -> String:
	return "VulnerableWindow (%s)" % [LimboUtility.decorate_var(vulnerable_duration_var)]

func _enter() -> void:
	_duration = blackboard.get_var(vulnerable_duration_var, 2.0)
	_timer = 0.0
	agent.is_exposed = true
	agent.get_node("Sprite2D").modulate = Color(1.0, 1.0, 0.3)

func _tick(delta: float) -> Status:
	_timer += delta
	# Flash effect while vulnerable
	if fmod(_timer, 0.2) < 0.1:
		agent.get_node("Sprite2D").modulate = Color(1.0, 1.0, 0.3)
	else:
		agent.get_node("Sprite2D").modulate = Color(1.0, 0.8, 0.2)
	if _timer >= _duration:
		return SUCCESS
	return RUNNING

func _exit() -> void:
	if is_instance_valid(agent):
		agent.is_exposed = false
		agent.get_node("Sprite2D").modulate = Color.WHITE
