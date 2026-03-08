extends LimboState

@export var animation_player: AnimationPlayer
@export var animation_name: String = "dash"
@export var dash_velocity: float = 400.0

var dash_movement_done: bool = false

func _enter() -> void:
	dash_movement_done = false
	animation_player.animation_finished.connect(_on_animation_finished)
	animation_player.play(animation_name)
	agent.dash(dash_velocity)

func _update(_delta: float) -> void:
	if not dash_movement_done:
		agent.move_and_slide()


func _exit() -> void:
	animation_player.animation_finished.disconnect(_on_animation_finished)


func _on_animation_finished(anim_name: String) -> void:
	if anim_name == animation_name:
		get_root().dispatch(EVENT_FINISHED)

func _dash_movement_ended() -> void:
	dash_movement_done = true
