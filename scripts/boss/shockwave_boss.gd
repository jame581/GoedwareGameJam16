extends CharacterBody2D


@export_group("References")
@export var target_player: CharacterBody2D

@export_group("Movement")
@export var move_speed: float = 100.0
@export var float_height: float = 50.0
@export var ground_height: float = 128.0

@export_group("Combat")
@export var attack_range: float = 30.0
@export var attack_cooldown: float = 5.0

@export_group("Shockwave Attack")
@export var shockwave_scene: PackedScene
@export var shockwave_projectile_speed: float = 200.0
@export var shockwave_summon_duration: float = 1.2
@export var shockwave_exposed_duration: float = 2.0
@export var shockwave_weight: float = 1.0

@export_group("Bomb Attack")
@export var bomb_scene: PackedScene
@export var bomb_count: int = 6
@export var bomb_spawn_interval: float = 0.3
@export var bomb_drop_height: float = -200.0
@export var bomb_arena_width: float = 800.0
@export var bomb_weight: float = 1.0

@onready var hsm: LimboHSM = $LimboHSM
@onready var approach_state: LimboState = $LimboHSM/ApproachState
@onready var summon_state: LimboState = $LimboHSM/SummonState
@onready var shockwave_state: LimboState = $LimboHSM/ShockwaveState
@onready var bomb_attack_state: LimboState = $LimboHSM/BombAttackState

var is_grounded: bool = false
var is_exposed: bool = false

func _ready() -> void:
	_init_state_machine()
	position.y = float_height


func _physics_process(_delta: float) -> void:
	if not is_grounded:
		position.y = lerp(position.y, float_height, 0.1)
	else:
		position.y = lerp(position.y, ground_height, 0.2)


func _init_state_machine() -> void:
	# Approach -> Decision (based on cycle)
	hsm.add_transition(approach_state, summon_state, "start_shockwave")
	hsm.add_transition(approach_state, bomb_attack_state, "start_bomb")

	# Path 1: Shockwave sequence
	# Summon (mid-air charge) -> Shockwave (land + spawn waves + vulnerable)
	hsm.add_transition(summon_state, shockwave_state, summon_state.EVENT_FINISHED)
	hsm.add_transition(shockwave_state, approach_state, shockwave_state.EVENT_FINISHED)

	# Path 2: Bomb sequence
	hsm.add_transition(bomb_attack_state, approach_state, bomb_attack_state.EVENT_FINISHED)

	hsm.initial_state = approach_state

	hsm.initialize(self)
	hsm.set_active(true)


func take_damage() -> void:
	if is_exposed:
		print("[ShockwaveBoss] Ouch!")
		hsm.blackboard.set_var("was_hit", true)


func set_exposed(exposed: bool) -> void:
	is_exposed = exposed
	if exposed:
		$ColorRect.color = Color(1.0, 1.0, 0.0) # Yellow for exposed
	else:
		$ColorRect.color = Color(0.6, 0.1, 0.1) # Red for normal


func get_direction_to_player() -> float:
	if not target_player:
		return 0.0
	return sign(target_player.global_position.x - global_position.x)


func is_within_threshold() -> bool:
	if not target_player:
		return false
	return abs(target_player.global_position.x - global_position.x) < attack_range


func spawn_shockwaves() -> void:
	if not shockwave_scene:
		push_warning("ShockwaveBoss: shockwave_scene not assigned!")
		return

	var left_wave: Area2D = shockwave_scene.instantiate()
	left_wave.direction = -1.0
	left_wave.speed = shockwave_projectile_speed
	left_wave.global_position = Vector2(global_position.x, ground_height)
	get_tree().current_scene.add_child(left_wave)

	var right_wave: Area2D = shockwave_scene.instantiate()
	right_wave.direction = 1.0
	right_wave.speed = shockwave_projectile_speed
	right_wave.global_position = Vector2(global_position.x, ground_height)
	get_tree().current_scene.add_child(right_wave)
