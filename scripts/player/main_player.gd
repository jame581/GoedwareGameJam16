extends CharacterBody2D


@export_group("Player Properties")
@export var camera: Camera2D
@export var movement_speed: float = 200.0
@export var jump_velocity: float = 400.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var remote_transform: RemoteTransform2D = $RemoteTransform2D
@onready var health: HealthComponent = $HealthComponent
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

#LimboHSM and LimboStates
@onready var hms: LimboHSM = $LimboHSM
@onready var idle_state: LimboState = $LimboHSM/IdleState
@onready var move_state: LimboState = $LimboHSM/MoveState
@onready var jump_state: LimboState = $LimboHSM/JumpState
@onready var dash_state: LimboState = $LimboHSM/DashState
@onready var fall_state: LimboState = $LimboHSM/FallState
@onready var light_attack_state: LimboState = $LimboHSM/LightAttackState
@onready var heavy_attack_state: LimboState = $LimboHSM/HeavyAttackState

func _ready() -> void:
	Global.register_player(self)
	_init_state_machine()

	move_state.speed = movement_speed
	jump_state.movement_speed = movement_speed
	jump_state.jump_velocity = jump_velocity
	fall_state.movement_speed = movement_speed

	if camera:
		remote_transform.remote_path = camera.get_path()

	health.damage_taken.connect(_on_damage_taken)
	health.died.connect(_on_died)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

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

	# Jump transitions
	hms.add_transition(idle_state, jump_state, "jump_started")
	hms.add_transition(move_state, jump_state, "jump_started")
	hms.add_transition(jump_state, fall_state, jump_state.EVENT_FINISHED)

	# Dash transitions (from move and jump only, not idle)
	hms.add_transition(move_state, dash_state, "dash_started")
	hms.add_transition(jump_state, dash_state, "dash_started")
	hms.add_transition(fall_state, dash_state, "dash_started")
	hms.add_transition(dash_state, fall_state, "dash_airborne")
	hms.add_transition(dash_state, move_state, dash_state.EVENT_FINISHED)

	# Fall transitions
	hms.add_transition(idle_state, fall_state, "fall_started")
	hms.add_transition(move_state, fall_state, "fall_started")
	hms.add_transition(fall_state, idle_state, fall_state.EVENT_FINISHED)

	# Light attack transitions (from idle and move, grounded only)
	hms.add_transition(idle_state, light_attack_state, "light_attack_started")
	hms.add_transition(move_state, light_attack_state, "light_attack_started")
	hms.add_transition(light_attack_state, idle_state, light_attack_state.EVENT_FINISHED)

	# Heavy attack transitions (from idle and move, grounded only)
	hms.add_transition(idle_state, heavy_attack_state, "heavy_attack_started")
	hms.add_transition(move_state, heavy_attack_state, "heavy_attack_started")
	hms.add_transition(heavy_attack_state, idle_state, heavy_attack_state.EVENT_FINISHED)

	hms.initial_state = idle_state

	hms.initialize(self)
	hms.set_active(true)


func move(direction: Vector2) -> void:
	velocity.x = direction.x
	flip_sprite(direction.x)
	move_and_slide()


func jump(new_jump_velocity: float = jump_velocity):
	velocity.y = new_jump_velocity


func dash(dash_velocity: float) -> void:
	velocity.x = dash_velocity * sign(velocity.x)


func flip_sprite(horizontal_direction: float) -> void:
	if horizontal_direction != 0.0:
		sprite.scale.x = sign(horizontal_direction)

func play_sound(stream: AudioStream) -> void:
	if stream and is_instance_valid(audio_player):
		audio_player.stream = stream
		audio_player.play()

func take_damage(amount: int) -> void:
	health.take_damage(amount)

func _on_damage_taken(_amount: int) -> void:
	sprite.modulate = Color(1.0, 0.3, 0.3)
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)

func _on_died() -> void:
	print("[Player] Died!")
