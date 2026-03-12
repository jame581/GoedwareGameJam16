@tool
extends BTCondition
## IsSmashReady: Returns SUCCESS if smash cooldown timer has elapsed.

@export var cooldown_var: StringName = &"smash_cooldown_timer"

func _generate_name() -> String:
	return "IsSmashReady (%s)" % [LimboUtility.decorate_var(cooldown_var)]

func _tick(_delta: float) -> Status:
	var timer: float = blackboard.get_var(cooldown_var, 0.0)
	if timer <= 0.0:
		return SUCCESS
	return FAILURE
