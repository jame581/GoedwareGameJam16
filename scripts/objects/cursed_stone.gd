extends Area2D
## Cursed Stone: Appears during boss stagger. Player can interact to trigger the sacrifice ending.
## Starts disabled — activated by boss_staggered signal.

@onready var sprite: Sprite2D = $Sprite2D

var _player_in_range: bool = false
var _active: bool = false

func _ready() -> void:
	# Disable interaction and collision until stagger
	set_process_unhandled_input(false)
	monitoring = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	SignalBus.boss_staggered.connect(_on_boss_staggered)

func _on_boss_staggered() -> void:
	_active = true
	monitoring = true
	set_process_unhandled_input(true)
	_set_interact_shader(true)

func _unhandled_input(event: InputEvent) -> void:
	if _active and _player_in_range and event.is_action_pressed("interact"):
		SignalBus.ending_triggered.emit("sacrifice")
		set_process_unhandled_input(false)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false

func _set_interact_shader(enabled: bool) -> void:
	var material: ShaderMaterial = sprite.material
	if not material:
		return
	material.set_shader_parameter("get_hit", enabled)
	material.set_shader_parameter("hit_effect", 0.6 if enabled else 0.0)
