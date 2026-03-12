@tool
extends BTAction
## ResetSpawnCooldown: Reset spawn cooldown timer on the blackboard.

@export var cooldown_var: StringName = &"spawn_cooldown_timer"
@export var cooldown_value: float = 10.0

func _generate_name() -> String:
	return "ResetSpawnCooldown (cd: %ss)" % [cooldown_value]

func _tick(_delta: float) -> Status:
	blackboard.set_var(cooldown_var, cooldown_value)
	return SUCCESS
