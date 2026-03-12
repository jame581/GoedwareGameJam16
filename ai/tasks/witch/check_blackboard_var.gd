@tool
extends BTCondition
## CheckBlackboardVar: Returns SUCCESS if a named boolean blackboard variable is true.

@export var variable: StringName = &"spawn_enabled"

func _generate_name() -> String:
	return "CheckVar %s == true" % [LimboUtility.decorate_var(variable)]

func _tick(_delta: float) -> Status:
	var value: bool = blackboard.get_var(variable, false)
	if value:
		return SUCCESS
	return FAILURE
