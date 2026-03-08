extends CharacterBody2D

const JUMP_VELOCITY = -400.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

#LimboHSM and LimboStates
@onready var hms: LimboHSM = $LimboHSM
@onready var idle_state: LimboState = $LimboHSM/IdleState
@onready var move_state: LimboState = $LimboHSM/MoveState
@onready var jump_state: LimboState = $LimboHSM/JumpState

func _ready() -> void:
	_init_state_machine()


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	# var direction := Input.get_axis("ui_left", "ui_right")
	# if direction:
	# 	velocity.x = direction * SPEED
	# else:
	# 	velocity.x = move_toward(velocity.x, 0, SPEED)

	# move_and_slide()


func _init_state_machine() -> void:
	# Set up the state machine transitions
	hms.add_transition(idle_state, move_state, idle_state.EVENT_FINISHED)
	hms.add_transition(move_state, idle_state, move_state.EVENT_FINISHED)

	hms.initial_state = idle_state

	hms.initialize(self)
	hms.set_active(true)


func move(direction: Vector2) -> void:
	velocity.x = direction.x
	flip_sprite(direction.x)
	move_and_slide()


func flip_sprite(horizontal_direction: float) -> void:
	if horizontal_direction != 0.0:
		sprite.scale.x = sign(horizontal_direction)
