extends LimboState

@export var animation_player: AnimationPlayer
@export var animation_name: String = "jump"
@export var jump_velocity: float = 400.0
@export var movement_speed: float = 200.0

var horizontal_direction: float = 0.0
var has_jumped: bool = false

func _enter() -> void:
	animation_player.play(animation_name)
	agent.jump(-jump_velocity)
	has_jumped = true

func _update(_delta: float) -> void:
	handle_input()

	var desired_velocity = Vector2(horizontal_direction * movement_speed, agent.velocity.y)
	agent.move(desired_velocity)

	if agent.is_on_floor():
		get_root().dispatch(EVENT_FINISHED)


func handle_input():
	# Get the input direction and handle the movement/deceleration.
	horizontal_direction = Input.get_axis(&"left", &"right")
