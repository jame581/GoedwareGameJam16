@tool
extends BTAction
## SlamDown: Rapidly move agent downward until on floor.

@export var slam_speed: float = 600.0

func _generate_name() -> String:
	return "SlamDown (speed: %s)" % [slam_speed]

func _enter() -> void:
	agent.velocity = Vector2(0, slam_speed)

func _tick(_delta: float) -> Status:
	if agent.is_on_floor():
		agent.velocity = Vector2.ZERO
		return SUCCESS
	agent.velocity = Vector2(0, slam_speed)
	return RUNNING
