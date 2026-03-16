extends Node2D

@export_enum("Intro", "Tutorial", "Boss Battle", "Outro", "Credits", "Main Menu") var next_level: String = "Main Menu"
@export var dialog_player: DialogPlayer
func _ready() -> void:
	if dialog_player:
		dialog_player.dialog_finished.connect(_on_dialog_finished)

	SignalBus.boss_died.connect(_on_boss_died)
	SignalBus.boss_staggered.connect(_on_boss_staggered)
	SignalBus.ending_triggered.connect(_on_ending_triggered)

func _on_boss_staggered() -> void:
	print("[GameLevel] Boss staggered signal received. Starting dialog sequence.")
	if dialog_player:
		# Set dialog nodes and their parent UI to process even when paused recursively
		_set_always_process(dialog_player)
		if dialog_player.dialog_display:
			_set_always_process(dialog_player.dialog_display)
			dialog_player.dialog_display.wait_for_input = true
			# Ensure the CanvasLayer parent also processes
			var dialog_ui = dialog_player.dialog_display.get_parent()
			if dialog_ui and dialog_ui is CanvasLayer:
				dialog_ui.process_mode = Node.PROCESS_MODE_ALWAYS

		# Pause the game tree
		print("[GameLevel] Pausing game tree for stagger dialog.")
		get_tree().paused = true

		# Set up the stagger dialog
		dialog_player.dialog_text_file = "res://resources/dialogs/boss_staggered_dialog.json"
		dialog_player.wait_for_input = true
		dialog_player.parse_json()
		dialog_player.next_message()

		# Reconnect dialog_finished to unpause the game
		if not dialog_player.dialog_finished.is_connected(_on_stagger_dialog_finished):
			dialog_player.dialog_finished.connect(_on_stagger_dialog_finished)
	else:
		print("[GameLevel] Warning: dialog_player not set, cannot show stagger dialog.")

func _set_always_process(node: Node) -> void:
	node.process_mode = Node.PROCESS_MODE_ALWAYS
	for child in node.get_children():
		_set_always_process(child)

func _on_stagger_dialog_finished() -> void:
	print("[GameLevel] Stagger dialog finished. Unpausing game.")
	get_tree().paused = false
	if dialog_player:
		# Note: We don't necessarily need to revert process mode if it doesn't hurt,
		# but let's keep it clean for future dialogs
		dialog_player.process_mode = Node.PROCESS_MODE_INHERIT
		if dialog_player.dialog_display:
			dialog_player.dialog_display.process_mode = Node.PROCESS_MODE_INHERIT

		if dialog_player.dialog_finished.is_connected(_on_stagger_dialog_finished):
			dialog_player.dialog_finished.disconnect(_on_stagger_dialog_finished)

func _on_dialog_finished() -> void:
	SignalBus.boss_activated.emit()
	AudioManager.play_music(AudioManager.main_game)
	if dialog_player and dialog_player.dialog_finished.is_connected(_on_dialog_finished):
		dialog_player.dialog_finished.disconnect(_on_dialog_finished)

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
