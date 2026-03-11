@tool
extends BTDecorator
## IsOnGround: Only ticks its child if the agent is on the floor (ground).

@export var invert: bool = false

func _generate_name() -> String:
	return "IsNotOnGround" if invert else "IsOnGround"

func _tick(delta: float) -> Status:
	if agent.has_method(&"is_on_floor"):
		var condition_met: bool = agent.is_on_floor() != invert
		if condition_met:
			if get_child_count() > 0:
				return get_child(0).execute(delta)
			return SUCCESS
		else:
			return FAILURE
	
	return FAILURE
