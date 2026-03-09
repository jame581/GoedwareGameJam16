extends CharacterBody2D


@export_group("Boss Properties")
@export var player: CharacterBody2D
@export var approach_speed: float = 100.0
@export var levitate_y: float = 50.0
@export var horizontal_threshold: float = 30.0

@export_group("Shockwave Properties")
@export var shockwave_scene: PackedScene
@export var shockwave_speed: float = 200.0
@export var floor_y: float = 128.0

@onready var hsm: LimboHSM = $LimboHSM
@onready var approach_state: LimboState = $LimboHSM/ApproachState
@onready var summon_state: LimboState = $LimboHSM/SummonState
@onready var shockwave_state: LimboState = $LimboHSM/ShockwaveState


func _ready() -> void:
	_init_state_machine()
	position.y = levitate_y


func _physics_process(_delta: float) -> void:
	position.y = levitate_y


func _init_state_machine() -> void:
	hsm.add_transition(approach_state, summon_state, "in_range")
	hsm.add_transition(summon_state, shockwave_state, summon_state.EVENT_FINISHED)
	hsm.add_transition(shockwave_state, approach_state, shockwave_state.EVENT_FINISHED)

	hsm.initial_state = approach_state

	hsm.initialize(self)
	hsm.set_active(true)


func get_direction_to_player() -> float:
	if not player:
		return 0.0
	return sign(player.global_position.x - global_position.x)


func is_within_threshold() -> bool:
	if not player:
		return false
	return abs(player.global_position.x - global_position.x) < horizontal_threshold


func spawn_shockwaves() -> void:
	if not shockwave_scene:
		push_warning("ShockwaveBoss: shockwave_scene not assigned!")
		return

	var left_wave: Area2D = shockwave_scene.instantiate()
	left_wave.direction = -1.0
	left_wave.speed = shockwave_speed
	left_wave.global_position = Vector2(global_position.x, floor_y)
	get_tree().current_scene.add_child(left_wave)

	var right_wave: Area2D = shockwave_scene.instantiate()
	right_wave.direction = 1.0
	right_wave.speed = shockwave_speed
	right_wave.global_position = Vector2(global_position.x, floor_y)
	get_tree().current_scene.add_child(right_wave)
