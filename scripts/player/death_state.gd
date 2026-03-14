extends LimboState

## Death state: plays death animation, emits player_died signal, disables player.

@export var animation_player: AnimationPlayer
@export var animation_name: String = "death"

func _enter() -> void:
	agent.velocity = Vector2.ZERO

	animation_player.play(animation_name)
	await animation_player.animation_finished

	SignalBus.player_died.emit()
	agent.set_physics_process(false)
