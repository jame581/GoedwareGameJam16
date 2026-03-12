@tool
extends BTAction
## SpawnShockwaves: Calls agent.spawn_shockwaves() to emit L+R projectiles.

func _generate_name() -> String:
	return "SpawnShockwaves"

func _tick(_delta: float) -> Status:
	agent.spawn_shockwaves()
	return SUCCESS
