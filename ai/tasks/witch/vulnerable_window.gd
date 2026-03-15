@tool
extends BTAction
## VulnerableWindow: Set agent as exposed for vulnerable_duration seconds.
## Uses the hit_effect shader with green flash to signal vulnerability.

@export var vulnerable_duration_var: StringName = &"vulnerable_duration"

var _timer: float = 0.0
var _duration: float = 0.0

func _generate_name() -> String:
	return "VulnerableWindow (%s)" % [LimboUtility.decorate_var(vulnerable_duration_var)]

func _enter() -> void:
	_duration = blackboard.get_var(vulnerable_duration_var, 2.0)
	_timer = 0.0
	agent.is_exposed = true
	_set_vulnerable_shader(true)

func _tick(delta: float) -> Status:
	_timer += delta
	if _timer >= _duration:
		return SUCCESS
	return RUNNING

func _exit() -> void:
	if is_instance_valid(agent):
		agent.is_exposed = false
		_set_vulnerable_shader(false)

func _set_vulnerable_shader(enabled: bool) -> void:
	var sprite: Sprite2D = agent.get_node("Sprite2D")
	var material: ShaderMaterial = sprite.material
	if not material:
		return
	if enabled:
		material.set_shader_parameter("get_hit", true)
		material.set_shader_parameter("hit_effect", 0.6)
		material.set_shader_parameter("shake_intensity", 1.0)
		material.set_shader_parameter("flash_speed", 15.0)
		material.set_shader_parameter("flash_color", Color(0.0, 1.0, 0.0, 1.0))
	else:
		material.set_shader_parameter("get_hit", false)
		material.set_shader_parameter("hit_effect", 0.0)
		material.set_shader_parameter("flash_speed", 30.0)
		material.set_shader_parameter("flash_color", Color(1.0, 0.0, 0.0, 1.0))
		sprite.modulate = Color.WHITE
