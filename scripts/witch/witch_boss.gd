extends CharacterBody2D

@export_group("References")
@export var shockwave_scene: PackedScene
@export var demon_scene: PackedScene

@export_group("Movement")
@export var move_speed: float = 60.0
@export var hover_y: float = -60.0
@export var ground_y: float = 76.0
@export var levitate_height: float = 80.0
@export var levitate_duration: float = 1.5

@export_group("Combat")
@export var active_by_default: bool = true
@export var phase2_threshold: float = 0.0
@export var shockwave_speed: float = 200.0

@export_group("Hit Effect")
@export var hit_flash_duration: float = 0.3
@export var hit_shake_intensity: float = 2.0

@export_group("Smash Attack")
@export var smash_cooldown: float = 1.5
@export var glow_duration_p1: float = 0.8
@export var glow_duration_p2: float = 0.5
@export var vulnerable_duration_p1: float = 2.5
@export var vulnerable_duration_p2: float = 1.2
@export var shockwave_spawn_offset: Vector2 = Vector2(0.0, 0.0)

@export_group("Stagger")
@export var stagger_threshold: float = 0.1
@export var spare_timer_duration: float = 10.0

@export_group("Demon Spawn")
@export var spawn_cooldown: float = 10.0
@export var demon_spawn_count_min: int = 1
@export var demon_spawn_count_max: int = 2

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var bt_player: BTPlayer = $BTPlayer
@onready var health: HealthComponent = $HealthComponent
@onready var hurtbox: HurtboxComponent = $Sprite2D/HurtBox

var is_exposed: bool = false
var is_attacking: bool = false
var is_phase2: bool = false
var is_staggered: bool = false
var _spare_timer: float = 0.0

func _ready() -> void:
	_setup_blackboard()
	health.damage_taken.connect(_on_damage_taken)
	health.died.connect(_on_died)
	hurtbox.hurt.connect(_on_hurtbox_hurt)
	SignalBus.boss_health_changed.emit(health.hp, health.max_hp)

	if is_instance_valid(bt_player):
		bt_player.set_active(active_by_default)

	SignalBus.boss_activated.connect(_on_boss_activated)
	animation_player.play("idle")

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
	bb.set_var(&"hover_y", hover_y)
	bb.set_var(&"ground_y", ground_y)
	bb.set_var(&"spawn_enabled", false)

func _physics_process(delta: float) -> void:
	# Re-acquire target if lost
	if is_instance_valid(bt_player):
		var target = bt_player.blackboard.get_var(&"target", null)
		if not is_instance_valid(target) and is_instance_valid(Global.player):
			bt_player.blackboard.set_var(&"target", Global.player)

	# Tick cooldown timers
	_tick_cooldowns(delta)

	# Stagger: apply gravity to bring boss to ground and tick spare timer
	if is_staggered:
		if not is_on_floor():
			velocity += get_gravity() * delta
		else:
			velocity = Vector2.ZERO
		_spare_timer += delta
		var time_left := spare_timer_duration - _spare_timer
		if time_left >= 0.0:
			SignalBus.spare_timer_updated.emit(time_left)
		if _spare_timer >= spare_timer_duration:
			SignalBus.ending_triggered.emit("spare")
			_spare_timer = -999.0  # Prevent re-triggering

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

	for dir in [-1.0, 1.0]:
		var wave: Area2D = shockwave_scene.instantiate()
		wave.direction = dir
		wave.speed = shockwave_speed
		wave.global_position = Vector2(global_position.x + shockwave_spawn_offset.x, global_position.y + shockwave_spawn_offset.y)
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
	_play_hit_effect()
	print("[WitchBoss] Hit! HP: %d/%d" % [health.hp, health.max_hp])
	SignalBus.boss_health_changed.emit(health.hp, health.max_hp)
	if is_staggered:
		_spare_timer = 0.0  # Reset spare timer — player chose to attack
	else:
		_check_phase_transition()
		_check_stagger()


func _play_hit_effect() -> void:
	var material: ShaderMaterial = sprite.material
	if not material:
		return
	material.set_shader_parameter("get_hit", true)
	material.set_shader_parameter("hit_effect", 1.0)
	material.set_shader_parameter("shake_intensity", hit_shake_intensity)
	var tween := create_tween()
	tween.tween_property(material, "shader_parameter/hit_effect", 0.0, hit_flash_duration)
	tween.tween_callback(_clear_hit_effect)


func _clear_hit_effect() -> void:
	var material: ShaderMaterial = sprite.material
	if material:
		material.set_shader_parameter("get_hit", false)
		material.set_shader_parameter("hit_effect", 0.0)

func _on_died() -> void:
	print("[WitchBoss] Defeated!")
	play_animation("death")
	# Wait for death animation to finish before transitioning
	await animation_player.animation_finished
	SignalBus.ending_triggered.emit("kill")
	queue_free()

func _check_stagger() -> void:
	if is_staggered:
		return
	if health.get_hp_ratio() <= stagger_threshold:
		_enter_stagger()

func _enter_stagger() -> void:
	is_staggered = true
	is_exposed = true
	is_attacking = false
	velocity = Vector2.ZERO
	_spare_timer = 0.0
	# Re-enable terrain collision so boss falls to ground with gravity
	collision_mask = 1
	play_animation("stage")
	if is_instance_valid(bt_player):
		bt_player.blackboard.set_var(&"is_staggered", true)
	print("[WitchBoss] Staggered! Choose: Kill, Spare, or Sacrifice.")
	SignalBus.boss_staggered.emit()

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
