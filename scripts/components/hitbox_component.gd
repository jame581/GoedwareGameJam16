class_name HitboxComponent
extends Area2D
## Deals damage to HurtboxComponents it overlaps with.
## Add a CollisionShape2D child to define the hit area.
##
## Setup: Set collision_mask in the scene to match the target's HurtboxComponent collision_layer.
## Example: Player hitbox mask=6 detects enemy hurtbox layer=6.

signal hit(hurtbox: HurtboxComponent)

@export var damage: int = 1
@export var enabled: bool = false:
	set(value):
		enabled = value
		monitoring = value
		if not value:
			_hit_targets.clear()

## If true, can only hit each target once per activation.
@export var one_hit_per_activation: bool = true

var _hit_targets: Array = []

func _ready() -> void:
	collision_layer = 0
	monitoring = enabled
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if not enabled:
		return
	if area is HurtboxComponent:
		var hurtbox: HurtboxComponent = area
		if one_hit_per_activation:
			var id := hurtbox.get_instance_id()
			if id in _hit_targets:
				return
			_hit_targets.append(id)
		print("[HitBox] %s hit %s for %d damage" % [owner.name if owner else name, hurtbox.owner.name if hurtbox.owner else hurtbox.name, damage])
		hurtbox.receive_hit(damage, self)
		hit.emit(hurtbox)
