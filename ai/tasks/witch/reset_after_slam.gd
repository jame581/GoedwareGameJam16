@tool
extends BTAction
## ResetAfterSlam: Reset smash cooldown and clear exposed flag.

@export var cooldown_var: StringName = &"smash_cooldown_timer"
@export var cooldown_value: float = 2.0

func _generate_name() -> String:
	return "ResetAfterSlam (cd: %ss)" % [cooldown_value]

func _tick(_delta: float) -> Status:
	blackboard.set_var(cooldown_var, cooldown_value)
	agent.is_exposed = false
	agent.is_attacking = false
	if agent.has_node("AnimationPlayer"):
		agent.get_node("AnimationPlayer").play("idle")
	return SUCCESS
