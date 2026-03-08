extends LimboState

@export var animation_player: AnimationPlayer
@export var animation_name: String = "fall"
@export var movement_speed: float = 200.0

var horizontal_direction: float = 0.0

func _enter() -> void:
	animation_player.play(animation_name)


func _update(_delta: float) -> void:
	handle_input()

	var desired_velocity = Vector2(horizontal_direction * movement_speed, agent.velocity.y)
	agent.move(desired_velocity)

	if agent.is_on_floor():
		get_root().dispatch(EVENT_FINISHED)


func handle_input():
	horizontal_direction = Input.get_axis(&"left", &"right")

	if Input.is_action_pressed("dash"):
		get_root().dispatch("dash_started")
