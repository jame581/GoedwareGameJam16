@tool
extends BTCondition
## DistanceGuard: Succeeds if the distance to [member target_var] meets the threshold condition.

## Blackboard variable that stores our target (expecting Node2D).
@export var target_var: StringName = &"target"

## Distance threshold.
@export var distance: float = 200.0

## If true, succeeds only when distance is LESS than threshold.
## If false, succeeds only when distance is GREATER than threshold.
@export var check_less_than: bool = true

func _generate_name() -> String:
	return "DistanceGuard %s %s %s" % [
		LimboUtility.decorate_var(target_var),
		"<" if check_less_than else ">",
		distance
	]

func _tick(_delta: float) -> Status:
	if not blackboard.has_var(target_var):
		return FAILURE

	var target: Node2D = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE

	var d: float = agent.global_position.distance_to(target.global_position)
	var condition_met: bool = (d < distance) if check_less_than else (d > distance)

	if condition_met:
		return SUCCESS
	return FAILURE
