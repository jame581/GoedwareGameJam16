@tool
extends BTDecorator
## DistanceGuard: Only ticks its child if the distance to [member target_var] is within [member distance] range.

## Blackboard variable that stores our target (expecting Node2D).
@export var target_var: StringName = &"target"

## Distance threshold.
@export var distance: float = 200.0

## If true, child runs only when distance is LESS than threshold.
## If false, child runs only when distance is GREATER than threshold.
@export var check_less_than: bool = true

func _generate_name() -> String:
	return "DistanceGuard %s %s %s" % [
		LimboUtility.decorate_var(target_var),
		"<" if check_less_than else ">",
		distance
	]

func _tick(delta: float) -> Status:
	if not blackboard.has_var(target_var):
		return FAILURE
		
	var target: Node2D = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE
	
	var d: float = agent.global_position.distance_to(target.global_position)
	var condition_met: bool = (d < distance) if check_less_than else (d > distance)
	
	if condition_met:
		# Tick the child task (e.g. Pursue) if it exists
		if get_child_count() > 0:
			return get_child(0).execute(delta)
		return SUCCESS
	else:
		# Return FAILURE so the tree knows the condition wasn't met
		return FAILURE
