extends Area2D
## Cursed Stone: Pre-placed in the level. Activates during boss stagger phase.

@export var interact_distance: float = 30.0

@onready var sprite: Sprite2D = $Sprite2D

var _player_in_range: bool = false
var _active: bool = false

func _ready() -> void:
	SignalBus.boss_staggered.connect(_on_boss_staggered)

func _on_boss_staggered() -> void:
	_active = true
	visible = true
	_set_interact_shader(true)

func _physics_process(_delta: float) -> void:
	if not _active:
		return

	var player := Global.player
	if not is_instance_valid(player):
		return

	_player_in_range = global_position.distance_to(player.global_position) <= interact_distance

func _input(event: InputEvent) -> void:
	if _active and _player_in_range and event.is_action_pressed("interact"):
		SignalBus.ending_triggered.emit("sacrifice")
		_active = false

func _set_interact_shader(enabled: bool) -> void:
	var material_shader: ShaderMaterial = sprite.material
	if not material_shader:
		return
	material_shader.set_shader_parameter("get_hit", enabled)
	material_shader.set_shader_parameter("hit_effect", 0.6 if enabled else 0.0)
