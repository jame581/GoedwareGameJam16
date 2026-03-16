extends LimboState

## Hurt state: brief stun with shader flash effect. Entered when player takes damage.

@export var hurt_duration: float = 0.4
@export var shake_intensity: float = 2.0
@export var hurt_sound: AudioStream

var _tween: Tween

func _enter() -> void:
	agent.velocity.x = 0.0
	agent.play_sound(hurt_sound)

	# Activate shader hit effect
	var material: ShaderMaterial = agent.sprite.material
	if material:
		material.set_shader_parameter("get_hit", true)
		material.set_shader_parameter("hit_effect", 1.0)
		material.set_shader_parameter("shake_intensity", shake_intensity)

		_tween = agent.create_tween()
		_tween.tween_property(material, "shader_parameter/hit_effect", 0.0, hurt_duration)
		_tween.tween_callback(_on_hurt_finished)
	else:
		# No shader material — just wait and exit
		get_tree().create_timer(hurt_duration).timeout.connect(_on_hurt_finished)


func _exit() -> void:
	var material: ShaderMaterial = agent.sprite.material
	if material:
		material.set_shader_parameter("get_hit", false)
		material.set_shader_parameter("hit_effect", 0.0)
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = null


func _on_hurt_finished() -> void:
	if is_active():
		get_root().dispatch(EVENT_FINISHED)
