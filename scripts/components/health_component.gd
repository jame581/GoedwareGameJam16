class_name HealthComponent
extends Node

signal health_changed(current_hp: int, max_hp: int)
signal damage_taken(amount: int)
signal died

@export var max_hp: int = 10
@export var invincibility_duration: float = 0.0

var hp: int
var is_invincible: bool = false

var _invincibility_timer: float = 0.0

func _ready() -> void:
	hp = max_hp

func _process(delta: float) -> void:
	if is_invincible and invincibility_duration > 0.0:
		_invincibility_timer -= delta
		if _invincibility_timer <= 0.0:
			is_invincible = false

func take_damage(amount: int) -> void:
	if hp <= 0 or is_invincible:
		return
	hp = maxi(hp - amount, 0)
	damage_taken.emit(amount)
	health_changed.emit(hp, max_hp)
	if invincibility_duration > 0.0:
		is_invincible = true
		_invincibility_timer = invincibility_duration
	if hp <= 0:
		died.emit()

func heal(amount: int) -> void:
	if hp <= 0:
		return
	hp = mini(hp + amount, max_hp)
	health_changed.emit(hp, max_hp)

func get_hp_ratio() -> float:
	return float(hp) / float(max_hp) if max_hp > 0 else 0.0
