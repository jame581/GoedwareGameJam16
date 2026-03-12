@tool
extends BTAction
## SpawnDemons: Calls agent.spawn_demons() to summon mob enemies.

func _generate_name() -> String:
	return "SpawnDemons"

func _tick(_delta: float) -> Status:
	agent.spawn_demons()
	return SUCCESS
