class_name HurtboxComponent
extends Area2D
## Receives hits from HitboxComponents and routes damage to a HealthComponent.
## Add a CollisionShape2D child to define the hurt area.
##
## Setup: Set collision_layer in the scene so enemy hitboxes can detect this.
## Example: Player hurtbox layer=5, enemy hitbox mask=5.
##
## If health_component is assigned, damage is applied automatically.
## Connect to the `hurt` signal to add custom logic (e.g. boss exposed check).

signal hurt(damage: int, hitbox: HitboxComponent)

## If set, damage is applied directly. Leave null to handle damage manually via the hurt signal.
@export var health_component: HealthComponent

func _ready() -> void:
	collision_mask = 0

func receive_hit(damage: int, hitbox: HitboxComponent) -> void:
	hurt.emit(damage, hitbox)
	if is_instance_valid(health_component):
		health_component.take_damage(damage)
