@tool
extends BTAction
## Detonate: Performs a countdown and then "explodes".

@export var fuse_time: float = 1.0
var _timer: float = 0.0

func _generate_name() -> String:
	return "Detonate (fuse: %ss)" % [fuse_time]

func _enter() -> void:
	_timer = fuse_time
	# Visual feedback: Turn Light Purple
	if agent.has_node("ColorRect"):
		agent.get_node("ColorRect").color = Color(0.8, 0.5, 1.0)
	
	if agent.has_node("AnimationPlayer"):
		agent.get_node("AnimationPlayer").play("idle") # Placeholder

func _tick(delta: float) -> Status:
	_timer -= delta
	
	# Rapid flash before exploding
	if agent.has_node("ColorRect"):
		if fmod(_timer, 0.1) < 0.05:
			agent.get_node("ColorRect").color = Color(0.8, 0.5, 1.0) # Light Purple
		else:
			agent.get_node("ColorRect").color = Color(0.4, 0.1, 0.6) # Dark Purple

	if _timer <= 0:
		print("BOOM! MobEnemy detonated at ", agent.global_position)
		# Add explosion logic here (damage, particles, etc.)
		agent.queue_free()
		return SUCCESS
	return RUNNING

func _exit() -> void:
	# Reset visual if interrupted
	if is_instance_valid(agent) and agent.has_node("ColorRect"):
		agent.get_node("ColorRect").color = Color(0.5, 0.2, 0.8) # Base Purple
