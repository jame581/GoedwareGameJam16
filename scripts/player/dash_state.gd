extends LimboState

@export var animation_player: AnimationPlayer
@export var animation_name: String = "dash"
@export var dash_velocity: float = 400.0

var dash_movement_done: bool = false
var was_airborne: bool = false

func _enter() -> void:
	dash_movement_done = false
	was_airborne = not agent.is_on_floor()
	if was_airborne:
		agent.velocity.y = 0.0
	animation_player.animation_finished.connect(_on_animation_finished)
	animation_player.play(animation_name)
	agent.dash(dash_velocity)

func _update(_delta: float) -> void:
	if was_airborne:
		agent.velocity.y = 0.0
	if not dash_movement_done:
		agent.move_and_slide()

	if dash_movement_done and not agent.is_on_floor():
		get_root().dispatch("dash_airborne")


func _exit() -> void:
	animation_player.animation_finished.disconnect(_on_animation_finished)


func _on_animation_finished(anim_name: String) -> void:
	if anim_name == animation_name:
		if not agent.is_on_floor():
			get_root().dispatch("dash_airborne")
		else:
			get_root().dispatch(EVENT_FINISHED)

func _dash_movement_ended() -> void:
	dash_movement_done = true
