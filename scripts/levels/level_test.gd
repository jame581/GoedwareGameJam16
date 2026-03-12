extends Node2D

@export_enum("Intro", "Tutorial", "Boss Battle", "Outro", "Credits", "Main Menu") var next_level: String = "Main Menu"
@export var transition_delay: float = 5.0

func _ready() -> void:
	await get_tree().create_timer(transition_delay).timeout
	
	match next_level:
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
