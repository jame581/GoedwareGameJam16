@tool
extends BTAction
## ReturnToHover: Smoothly lerp agent back to hover_y position after a slam.

@export var hover_y_var: StringName = &"hover_y"
@export var rise_speed: float = 3.0

func _generate_name() -> String:
	return "ReturnToHover (%s)" % [LimboUtility.decorate_var(hover_y_var)]

func _enter() -> void:
	if agent.is_staggered:
		return
	agent.is_attacking = true
	agent.velocity = Vector2.ZERO

func _tick(delta: float) -> Status:
	if agent.is_staggered:
		return SUCCESS
	var target_y: float = blackboard.get_var(hover_y_var, -60.0)
	agent.global_position.y = lerpf(agent.global_position.y, target_y, 1.0 - exp(-rise_speed * delta))
	agent.velocity = Vector2.ZERO
	if absf(agent.global_position.y - target_y) < 2.0:
		agent.global_position.y = target_y
		return SUCCESS
	return RUNNING

func _exit() -> void:
	if is_instance_valid(agent) and not agent.is_staggered:
		agent.is_attacking = false
