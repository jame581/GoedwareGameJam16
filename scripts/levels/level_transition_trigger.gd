extends Area2D

@export_enum("Intro", "Tutorial", "Boss Battle", "Outro", "Credits", "Main Menu") var target_level: String = "Boss Battle"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_transition()

func _transition() -> void:
	match target_level:
		"Intro":
			SceneChanger.goto_intro()
		"Tutorial":
			SceneChanger.goto_tutorial()
		"Boss Battle":
			SceneChanger.goto_boss_battle()
		"Outro":
			SceneChanger.goto_outro()
		"Credits":
			SceneChanger.goto_credits()
		"Main Menu":
			SceneChanger.goto_main_menu()
