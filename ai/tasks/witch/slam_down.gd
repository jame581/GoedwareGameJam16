@tool
extends BTAction
## SlamDown: Rapidly move agent downward until reaching ground_y or hitting an obstacle.

@export var slam_speed: float = 600.0
@export var ground_y_var: StringName = &"ground_y"

func _generate_name() -> String:
	return "SlamDown (speed: %s)" % [slam_speed]

func _enter() -> void:
	# Enable terrain collision for obstacle detection during slam
	agent.collision_mask = 1
	agent.play_animation("smash")
	agent.velocity = Vector2(0, slam_speed)

func _tick(_delta: float) -> Status:
	var target_y: float = blackboard.get_var(ground_y_var, 200.0)
	if agent.global_position.y >= target_y or agent.is_on_floor():
		agent.velocity = Vector2.ZERO
		return SUCCESS
	agent.velocity = Vector2(0, slam_speed)
	return RUNNING

func _exit() -> void:
	# Disable terrain collision so boss flies freely
	if is_instance_valid(agent):
		agent.collision_mask = 0
