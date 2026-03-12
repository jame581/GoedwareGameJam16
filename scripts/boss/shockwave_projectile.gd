extends Area2D

@export var speed: float = 200.0
@export var direction: float = 1.0
@export var lifetime: float = 5.0
@export var damage: int = 1

var _elapsed: float = 0.0


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	position.x += direction * speed * delta

	_elapsed += delta
	if _elapsed >= lifetime:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area is HurtboxComponent:
		area.receive_hit(damage, null)
		queue_free()
