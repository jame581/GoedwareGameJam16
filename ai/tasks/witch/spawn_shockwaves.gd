@tool
extends BTAction
## SpawnShockwaves: Calls agent.spawn_shockwaves() to emit L+R projectiles.
## When boss HP is below 50%, spawns a second wave after a delay.

func _generate_name() -> String:
	return "SpawnShockwaves"

func _tick(_delta: float) -> Status:
	agent.play_sound(agent.shockwave_sound)
	agent.spawn_shockwaves()
	if agent.health.get_hp_ratio() <= 0.5:
		agent.get_tree().create_timer(agent.half_hp_burst_delay).timeout.connect(agent.spawn_shockwaves)
	return SUCCESS
