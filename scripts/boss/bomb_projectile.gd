extends Area2D

const MAX_FALL_Y: float = 500.0

@export var initial_fall_speed: float = 50.0
@export var acceleration: float = 500.0
@export var hover_duration: float = 0.5

var _velocity: float = 0.0
var _is_falling: bool = false


func _ready() -> void:
	_velocity = initial_fall_speed
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), hover_duration * 0.5)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), hover_duration * 0.5)
	tween.tween_callback(_start_falling)


func _start_falling() -> void:
	_is_falling = true


func _physics_process(delta: float) -> void:
	if _is_falling:
		_velocity += acceleration * delta
		global_position.y += _velocity * delta
		if global_position.y > MAX_FALL_Y:
			queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		explode()


func explode() -> void:
	# TODO: Add explosion effect/damage logic later
	print("[Bomb] BOOM at ", global_position)
	queue_free()
