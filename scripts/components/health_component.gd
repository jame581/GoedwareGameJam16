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
	var entity_name := owner.name if owner else name
	if hp <= 0:
		print("[Health] %s already dead, ignoring %d damage" % [entity_name, amount])
		return
	if is_invincible:
		print("[Health] %s is invincible, ignoring %d damage" % [entity_name, amount])
		return
	hp = maxi(hp - amount, 0)
	print("[Health] %s took %d damage — HP: %d/%d" % [entity_name, amount, hp, max_hp])
	damage_taken.emit(amount)
	health_changed.emit(hp, max_hp)
	if invincibility_duration > 0.0:
		is_invincible = true
		_invincibility_timer = invincibility_duration
		print("[Health] %s invincible for %.1fs" % [entity_name, invincibility_duration])
	if hp <= 0:
		print("[Health] %s died!" % [entity_name])
		died.emit()

func heal(amount: int) -> void:
	var entity_name := owner.name if owner else name
	if hp <= 0:
		return
	var old_hp := hp
	hp = mini(hp + amount, max_hp)
	print("[Health] %s healed %d — HP: %d/%d" % [entity_name, hp - old_hp, hp, max_hp])
	health_changed.emit(hp, max_hp)

func get_hp_ratio() -> float:
	return float(hp) / float(max_hp) if max_hp > 0 else 0.0
