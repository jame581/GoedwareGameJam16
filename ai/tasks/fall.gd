@tool
extends BTAction
## Fall: Move down until agent hits the ground (is_on_floor).

@export var max_fall_speed: float = 1000.0

var _current_fall_speed: float = 0.0
var _gravity: float = 980.0

func _generate_name() -> String:
	return "Fall"

func _enter() -> void:
	_current_fall_speed = 0.0
	_gravity = ProjectSettings.get_setting("physics/2d/default_gravity", 980.0)

func _tick(delta: float) -> Status:
	if agent.has_method(&"is_on_floor") and agent.is_on_floor():
		return SUCCESS

	# Accelerate downwards using gravity
	_current_fall_speed = minf(_current_fall_speed + _gravity * delta, max_fall_speed)
	
	agent.move(Vector2(0, _current_fall_speed))
	
	return RUNNING
