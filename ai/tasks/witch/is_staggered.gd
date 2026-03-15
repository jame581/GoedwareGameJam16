@tool
extends BTCondition
## IsStaggered: Returns SUCCESS if boss is in stagger state (low HP).

func _generate_name() -> String:
	return "IsStaggered"

func _tick(_delta: float) -> Status:
	var staggered: bool = blackboard.get_var(&"is_staggered", false)
	if staggered:
		return SUCCESS
	return FAILURE
