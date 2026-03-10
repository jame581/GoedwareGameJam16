@tool
extends BTAction
## Pursue: Move towards the target until within [member approach_distance] range.

## How close should the agent be to the target position to return SUCCESS.
const TOLERANCE := 30.0

## Blackboard variable that stores our target (expecting Node2D).
@export var target_var: StringName = &"target"

## Blackboard variable that stores desired speed.
@export var speed_var: StringName = &"speed"

## Desired distance from target.
@export var approach_distance: float = 0.0

var _waypoint: Vector2

func _generate_name() -> String:
	return "Pursue %s" % [LimboUtility.decorate_var(target_var)]

func _enter() -> void:
	var target: Node2D = blackboard.get_var(target_var, null)
	if is_instance_valid(target):
		_select_new_waypoint(_get_desired_position(target))

func _tick(_delta: float) -> Status:
	var target: Node2D = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE

	var desired_pos: Vector2 = _get_desired_position(target)
	if agent.global_position.distance_to(desired_pos) < TOLERANCE:
		return SUCCESS

	if agent.global_position.distance_to(_waypoint) < TOLERANCE:
		_select_new_waypoint(desired_pos)

	var speed: float = blackboard.get_var(speed_var, 200.0)
	var desired_velocity: Vector2 = agent.global_position.direction_to(_waypoint) * speed
	agent.move(desired_velocity)
	
	if agent.has_method(&"update_facing"):
		agent.update_facing()
		
	return RUNNING

func _get_desired_position(target: Node2D) -> Vector2:
	var dir_to_agent: Vector2 = target.global_position.direction_to(agent.global_position)
	return target.global_position + dir_to_agent * approach_distance

func _select_new_waypoint(desired_position: Vector2) -> void:
	var distance_vector: Vector2 = desired_position - agent.global_position
	# Add a bit of "wobble" to movement
	var angle_variation: float = randf_range(-0.1, 0.1)
	_waypoint = agent.global_position + distance_vector.limit_length(100.0).rotated(angle_variation)
