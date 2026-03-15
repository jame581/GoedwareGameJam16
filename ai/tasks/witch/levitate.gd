@tool
extends BTAction
## Levitate: Move the agent upward over a duration. Reads values from blackboard.

@export var rise_height_var: StringName = &"levitate_height"
@export var rise_duration_var: StringName = &"levitate_duration"

var _timer: float = 0.0
var _start_y: float = 0.0
var _height: float = 80.0
var _duration: float = 1.5

func _generate_name() -> String:
	return "Levitate (%s, %s)" % [
		LimboUtility.decorate_var(rise_height_var),
		LimboUtility.decorate_var(rise_duration_var)]

func _enter() -> void:
	_height = blackboard.get_var(rise_height_var, 80.0)
	_duration = blackboard.get_var(rise_duration_var, 1.5)
	_timer = 0.0
	_start_y = agent.global_position.y
	agent.is_attacking = true
	agent.velocity = Vector2.ZERO

func _tick(delta: float) -> Status:
	_timer += delta
	var t := clampf(_timer / _duration, 0.0, 1.0)
	agent.global_position.y = lerpf(_start_y, _start_y - _height, t)
	agent.velocity = Vector2.ZERO
	if t >= 1.0:
		return SUCCESS
	return RUNNING
