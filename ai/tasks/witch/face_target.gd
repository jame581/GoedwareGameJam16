@tool
extends BTAction
## FaceTarget: Flip the agent's sprite to face the blackboard target.

@export var target_var: StringName = &"target"

func _generate_name() -> String:
	return "FaceTarget %s" % [LimboUtility.decorate_var(target_var)]

func _tick(_delta: float) -> Status:
	var target: Node2D = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE
	agent.face_toward(target)
	return SUCCESS
