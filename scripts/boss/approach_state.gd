extends LimboState

var _timer: float = 0.0

func _enter() -> void:
	_timer = 0.0

func _update(delta: float) -> void:
	_timer += delta

	if _timer >= agent.attack_cooldown and agent.is_within_threshold():
		_choose_and_dispatch_attack()
		return

	var direction: float = agent.get_direction_to_player()
	agent.velocity = Vector2(direction * agent.move_speed, 0.0)
	agent.move_and_slide()

func _choose_and_dispatch_attack() -> void:
	var total_weight: float = agent.shockwave_weight + agent.bomb_weight
	if total_weight <= 0.0:
		get_root().dispatch("start_shockwave") # Fallback
		return
		
	var random_val: float = randf_range(0.0, total_weight)
	
	if random_val <= agent.shockwave_weight:
		get_root().dispatch("start_shockwave")
	else:
		get_root().dispatch("start_bomb")
