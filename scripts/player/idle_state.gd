extends LimboState

@export var animation_player: AnimationPlayer
@export var animation_name: String = "idle"

var horizontal_direction: float = 0.0

func _enter() -> void:
	animation_player.play(animation_name)


func _update(_delta: float) -> void:
	_handle_input()

	if not agent.is_on_floor():
		get_root().dispatch("fall_started")
		return

	if horizontal_direction != 0.0:
		get_root().dispatch(EVENT_FINISHED)

	# This is important to keep the agent's physics updated even in idle state (for example to handle gravity or platform movement)
	agent.move(Vector2.ZERO)

func _handle_input() -> void:
	# Get the input direction and handle the movement/deceleration.
	horizontal_direction = Input.get_axis(&"left", &"right")

	if (Input.is_action_pressed("jump") and agent.is_on_floor()):
		get_root().dispatch("jump_started")

	if Input.is_action_just_pressed("light_attack"):
		get_root().dispatch("light_attack_started")

	if Input.is_action_just_pressed("heavy_attack"):
		get_root().dispatch("heavy_attack_started")
