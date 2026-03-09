extends Area2D

@export var speed: float = 200.0
@export var direction: float = 1.0
@export var lifetime: float = 5.0

var _elapsed: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position.x += direction * speed * delta

	_elapsed += delta
	if _elapsed >= lifetime:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		print("[Shockwave] Hit player: ", body.name)
