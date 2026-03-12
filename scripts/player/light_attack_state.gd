extends LimboState

## Light attack: fast but low damage. Player can turn before attacking.

@export var animation_player: AnimationPlayer
@export var animation_name: String = "light_attack"
@export var damage: int = 1
@export var hitbox: HitboxComponent

func _enter() -> void:
	var horizontal_direction = Input.get_axis(&"left", &"right")
	if horizontal_direction != 0.0:
		agent.flip_sprite(horizontal_direction)

	if hitbox:
		hitbox.damage = damage
		hitbox.enabled = true

	animation_player.play(animation_name)
	await animation_player.animation_finished
	if hitbox:
		hitbox.enabled = false
	if is_active():
		get_root().dispatch(EVENT_FINISHED)
