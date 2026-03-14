extends Node2D

@export_enum("Intro", "Tutorial", "Boss Battle", "Outro", "Credits", "Main Menu") var next_level: String = "Main Menu"
@export var dialog_player: DialogPlayer

func _ready() -> void:
	if dialog_player:
		dialog_player.dialog_finished.connect(_on_dialog_finished)
	
	SignalBus.boss_died.connect(_on_boss_died)

func _on_dialog_finished() -> void:
	SignalBus.boss_activated.emit()

func _on_boss_died() -> void:
	# Add a small delay after boss dies before transition
	await get_tree().create_timer(2.0).timeout
	_transition()

func _transition() -> void:
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
