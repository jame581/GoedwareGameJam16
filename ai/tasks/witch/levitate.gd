@tool
extends BTAction
## Levitate: Move the agent upward over a duration.

@export var rise_height: float = 80.0
@export var rise_duration: float = 0.5

var _timer: float = 0.0
var _start_y: float = 0.0

func _generate_name() -> String:
	return "Levitate (height: %s, dur: %ss)" % [rise_height, rise_duration]

func _enter() -> void:
	_timer = 0.0
	_start_y = agent.global_position.y

func _tick(delta: float) -> Status:
	_timer += delta
	var t := clampf(_timer / rise_duration, 0.0, 1.0)
	agent.global_position.y = lerpf(_start_y, _start_y - rise_height, t)
	agent.velocity = Vector2.ZERO
	if t >= 1.0:
		return SUCCESS
	return RUNNING
