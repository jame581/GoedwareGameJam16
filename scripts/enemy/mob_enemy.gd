extends CharacterBody2D

@export var speed: float = 150.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var bt_player: BTPlayer = $BTPlayer

var _moved_this_frame: bool = false

func _ready() -> void:
	# Try to register immediately, or wait for Global to have a player
	_update_bt_target()

func _update_bt_target() -> void:
	if is_instance_valid(bt_player) and is_instance_valid(Global.player):
		bt_player.blackboard.set_var(&"target", Global.player)

func _physics_process(_delta: float) -> void:
	# Keep target updated if it was null at start
	if not bt_player.blackboard.has_var(&"target") or bt_player.blackboard.get_var(&"target") == null:
		_update_bt_target()
		
	if not _moved_this_frame:
		velocity = Vector2.ZERO
	move_and_slide()
	_moved_this_frame = false

## Move method used by BT tasks
func move(p_velocity: Vector2) -> void:
	velocity = p_velocity
	_moved_this_frame = true

## Update facing based on velocity
func update_facing() -> void:
	if velocity.x != 0:
		sprite.scale.x = sign(velocity.x)
