extends LimboState

@export var animation_player: AnimationPlayer
@export var animation_name: String = "run"
@export var speed: float = 300.0

var horizontal_direction: float = 0.0

func _enter() -> void:
	animation_player.play(animation_name)


func _update(_delta: float) -> void:
	_handle_input()

	agent.move(Vector2(horizontal_direction * speed, 0))

	if horizontal_direction == 0.0:
		get_root().dispatch(EVENT_FINISHED)


func _handle_input() -> void:
	# Get the input direction and handle the movement/deceleration.
	horizontal_direction = Input.get_axis(&"left", &"right")
