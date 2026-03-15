extends Node2D

@export_enum("Intro", "Tutorial", "Boss Battle", "Outro", "Credits", "Main Menu") var next_level: String = "Main Menu"
@export var dialog_player: DialogPlayer
@export var cursed_stone_scene: PackedScene
@export var cursed_stone_position: Vector2 = Vector2(0, 76)

func _ready() -> void:
	if dialog_player:
		dialog_player.dialog_finished.connect(_on_dialog_finished)

	SignalBus.boss_died.connect(_on_boss_died)
	SignalBus.boss_staggered.connect(_on_boss_staggered)
	SignalBus.ending_triggered.connect(_on_ending_triggered)

func _on_dialog_finished() -> void:
	SignalBus.boss_activated.emit()

func _on_boss_staggered() -> void:
	if cursed_stone_scene:
		var stone := cursed_stone_scene.instantiate()
		stone.global_position = cursed_stone_position
		add_child(stone)

func _on_ending_triggered(ending_type: String) -> void:
	match ending_type:
		"kill":
			await get_tree().create_timer(2.0).timeout
			SceneChanger.goto_save_father_ending()
		"spare":
			await get_tree().create_timer(1.0).timeout
			SceneChanger.goto_save_mother_ending()
		"sacrifice":
			SceneChanger.goto_save_both_ending()

func _on_boss_died() -> void:
	# Fallback if boss dies without stagger (e.g. one-shot from above threshold)
	await get_tree().create_timer(2.0).timeout
	SceneChanger.goto_save_father_ending()

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
