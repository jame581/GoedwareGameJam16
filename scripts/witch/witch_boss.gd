extends CharacterBody2D

@export_group("References")
@export var shockwave_scene: PackedScene
@export var demon_scene: PackedScene

@export_group("Movement")
@export var move_speed: float = 60.0
@export var levitate_height: float = 80.0
@export var levitate_duration: float = 1.5

@export_group("Combat")
@export var active_by_default: bool = true
@export var phase2_threshold: float = 0.5
@export var shockwave_speed: float = 200.0

@export_group("Smash Attack")
@export var smash_cooldown: float = 2.0
@export var glow_duration_p1: float = 0.8
@export var glow_duration_p2: float = 0.5
@export var vulnerable_duration_p1: float = 5.0
@export var vulnerable_duration_p2: float = 1.2

@export_group("Demon Spawn")
@export var spawn_cooldown: float = 10.0
@export var demon_spawn_count_min: int = 1
@export var demon_spawn_count_max: int = 2

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var bt_player: BTPlayer = $BTPlayer
@onready var health: HealthComponent = $HealthComponent
@onready var hurtbox: HurtboxComponent = $HurtBox

var is_exposed: bool = false
var is_attacking: bool = false
var is_phase2: bool = false
var _original_y: float

func _ready() -> void:
	_original_y = global_position.y
	_setup_blackboard()
	health.damage_taken.connect(_on_damage_taken)
	health.died.connect(_on_died)
	hurtbox.hurt.connect(_on_hurtbox_hurt)
	SignalBus.boss_health_changed.emit(health.hp, health.max_hp)
	
	if is_instance_valid(bt_player):
		bt_player.set_active(active_by_default)
	
	SignalBus.boss_activated.connect(_on_boss_activated)

func _on_boss_activated() -> void:
	if is_instance_valid(bt_player):
		bt_player.set_active(true)

func _setup_blackboard() -> void:
	if not is_instance_valid(bt_player):
		return
	var bb := bt_player.blackboard
	bb.set_var(&"target", Global.player)
	bb.set_var(&"speed", move_speed)
	bb.set_var(&"smash_cooldown_timer", 0.0)
	bb.set_var(&"spawn_cooldown_timer", spawn_cooldown)
	bb.set_var(&"glow_duration", glow_duration_p1)
	bb.set_var(&"vulnerable_duration", vulnerable_duration_p1)
	bb.set_var(&"levitate_height", levitate_height)
	bb.set_var(&"levitate_duration", levitate_duration)
	bb.set_var(&"spawn_enabled", false)

func _physics_process(delta: float) -> void:
	# Re-acquire target if lost
	if is_instance_valid(bt_player):
		var target = bt_player.blackboard.get_var(&"target", null)
		if not is_instance_valid(target) and is_instance_valid(Global.player):
			bt_player.blackboard.set_var(&"target", Global.player)

	# Tick cooldown timers
	_tick_cooldowns(delta)

	# Gravity (suppressed during attack sequences like levitate/slam)
	if not is_on_floor() and not is_attacking:
		velocity += get_gravity() * delta

	move_and_slide()

func _tick_cooldowns(delta: float) -> void:
	if not is_instance_valid(bt_player):
		return
	var bb := bt_player.blackboard

	var smash_cd: float = bb.get_var(&"smash_cooldown_timer", 0.0)
	if smash_cd > 0.0:
		bb.set_var(&"smash_cooldown_timer", smash_cd - delta)

	var spawn_cd: float = bb.get_var(&"spawn_cooldown_timer", 0.0)
	if spawn_cd > 0.0:
		bb.set_var(&"spawn_cooldown_timer", spawn_cd - delta)

## API for BT tasks
func move(p_velocity: Vector2) -> void:
	velocity = p_velocity

func update_facing() -> void:
	if velocity.x != 0:
		sprite.flip_h = velocity.x > 0

func face_toward(target: Node2D) -> void:
	if is_instance_valid(target):
		sprite.flip_h = target.global_position.x > global_position.x

func spawn_shockwaves() -> void:
	if not shockwave_scene:
		push_warning("WitchBoss: shockwave_scene not assigned!")
		return

	var ground_y := global_position.y
	for dir in [-1.0, 1.0]:
		var wave: Area2D = shockwave_scene.instantiate()
		wave.direction = dir
		wave.speed = shockwave_speed
		wave.global_position = Vector2(global_position.x, ground_y)
		get_tree().current_scene.add_child(wave)

func spawn_demons() -> void:
	if not demon_scene:
		push_warning("WitchBoss: demon_scene not assigned!")
		return

	var count := randi_range(demon_spawn_count_min, demon_spawn_count_max)
	for i in count:
		var demon: CharacterBody2D = demon_scene.instantiate()
		var offset_x := randf_range(-40.0, 40.0)
		demon.global_position = Vector2(global_position.x + offset_x, global_position.y - 20.0)
		get_tree().current_scene.add_child(demon)

func _on_hurtbox_hurt(damage: int, _hitbox: HitboxComponent) -> void:
	if not is_exposed:
		return
	health.take_damage(damage)

func _on_damage_taken(_amount: int) -> void:
	sprite.modulate = Color(1.0, 0.3, 0.3)
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)
	print("[WitchBoss] Hit! HP: %d/%d" % [health.hp, health.max_hp])
	SignalBus.boss_health_changed.emit(health.hp, health.max_hp)
	_check_phase_transition()

func _on_died() -> void:
	print("[WitchBoss] Defeated!")
	SignalBus.boss_died.emit()
	queue_free()

func _check_phase_transition() -> void:
	if is_phase2:
		return
	if health.get_hp_ratio() <= phase2_threshold:
		is_phase2 = true
		print("[WitchBoss] Phase 2!")
		var bb := bt_player.blackboard
		bb.set_var(&"glow_duration", glow_duration_p2)
		bb.set_var(&"vulnerable_duration", vulnerable_duration_p2)
		bb.set_var(&"spawn_enabled", true)

func play_animation(anim_name: String) -> void:
	if is_instance_valid(animation_player):
		animation_player.play(anim_name)
