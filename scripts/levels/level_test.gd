extends Node2D

@export var fast_path: bool

func _ready() -> void:
	if fast_path:
		await get_tree().create_timer(5.0).timeout
		SceneChanger.goto_outro()
