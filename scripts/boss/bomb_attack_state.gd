extends LimboState

var _spawned_count: int = 0
var _timer: float = 0.0
var _spawn_positions: Array[float] = []
var _is_finished: bool = false

func _enter() -> void:
	_spawned_count = 0
	_timer = 0.0
	_is_finished = false
	_spawn_positions.clear()

	# Determine sequence direction: start from side where player is
	var player_x: float = agent.target_player.global_position.x if agent.target_player else 0.0
	var start_from_right: bool = player_x > agent.global_position.x

	# Create positions across the map
	var step: float = agent.bomb_arena_width / max(agent.bomb_count - 1, 1)
	var start_x: float = agent.global_position.x - (agent.bomb_arena_width / 2.0)

	for i in range(agent.bomb_count):
		_spawn_positions.append(start_x + (i * step))

	if start_from_right:
		_spawn_positions.reverse()

	print("[ShockwaveBoss] Bomb Attack Started! Spawning from ", "Right" if start_from_right else "Left")

func _update(delta: float) -> void:
	if _is_finished:
		return

	_timer += delta
	if _timer >= agent.bomb_spawn_interval and _spawned_count < agent.bomb_count:
		_spawn_bomb(_spawn_positions[_spawned_count])
		_spawned_count += 1
		_timer = 0.0

	if _spawned_count >= agent.bomb_count:
		# Small delay before finishing the state so the last bomb has time to start falling
		if _timer >= 1.0:
			_is_finished = true
			get_root().dispatch(EVENT_FINISHED)

func _spawn_bomb(x_pos: float) -> void:
	if not agent.bomb_scene:
		return
	var bomb: Area2D = agent.bomb_scene.instantiate()
	bomb.global_position = Vector2(x_pos, agent.bomb_drop_height)
	get_tree().current_scene.add_child(bomb)
