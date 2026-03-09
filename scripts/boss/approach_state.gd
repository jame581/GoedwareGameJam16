extends LimboState


func _update(_delta: float) -> void:
	if agent.is_within_threshold():
		get_root().dispatch("in_range")
		return

	var direction: float = agent.get_direction_to_player()
	agent.velocity = Vector2(direction * agent.approach_speed, 0.0)
	agent.move_and_slide()
	agent.position.y = agent.levitate_y
