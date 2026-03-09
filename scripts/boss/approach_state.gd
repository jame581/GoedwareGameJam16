extends LimboState


func _enter() -> void:
	if not blackboard.has_var("use_shockwave"):
		blackboard.set_var("use_shockwave", true)


func _update(_delta: float) -> void:
	if agent.is_within_threshold():
		var use_shockwave: bool = blackboard.get_var("use_shockwave", true)
		if use_shockwave:
			get_root().dispatch("start_shockwave")
		else:
			get_root().dispatch("start_bomb")
		blackboard.set_var("use_shockwave", !use_shockwave)
		return

	var direction: float = agent.get_direction_to_player()
	agent.velocity = Vector2(direction * agent.approach_speed, 0.0)
	agent.move_and_slide()
