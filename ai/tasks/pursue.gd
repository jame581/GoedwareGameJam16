@tool
extends BTAction
## Pursue: Move towards the target horizontally until within [member approach_distance] range.

## How close should the agent be to the target position to return SUCCESS.
const TOLERANCE := 30.0

## Blackboard variable that stores our target (expecting Node2D).
@export var target_var: StringName = &"target"

## Blackboard variable that stores desired speed.
@export var speed_var: StringName = &"speed"

## Optional animation to play while pursuing. Agent must have a method `play_animation(String)` for this to work.
@export var animation: String = "move"

## Desired distance from target.
@export var approach_distance: float = 0.0

var _target: Node2D

func _generate_name() -> String:
	return "Pursue %s" % [LimboUtility.decorate_var(target_var)]

func _enter() -> void:
	_target = blackboard.get_var(target_var, null)
	if is_instance_valid(agent) and animation != "":
		agent.play_animation(animation)

func _tick(_delta: float) -> Status:
	if not is_instance_valid(_target):
		return FAILURE

	var dist_x: float = abs(_target.global_position.x - agent.global_position.x)

	# Check if we reached the desired distance (with tolerance)
	if dist_x <= approach_distance + TOLERANCE:
		return SUCCESS

	var speed: float = blackboard.get_var(speed_var, 200.0)
	var dir_x: float = sign(_target.global_position.x - agent.global_position.x)
	var desired_velocity := Vector2(dir_x * speed, 0.0)

	agent.move(desired_velocity)

	if agent.has_method(&"update_facing"):
		agent.update_facing()

	return RUNNING
