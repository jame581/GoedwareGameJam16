extends Control

## Game Over menu: shown when the player dies. Pauses the game tree.

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	visible = false
	mouse_filter = MOUSE_FILTER_IGNORE
	SignalBus.player_died.connect(_on_player_died)


func _on_player_died() -> void:
	visible = true
	mouse_filter = MOUSE_FILTER_STOP
	get_tree().paused = true


func _on_restart_button_pressed() -> void:
	AudioManager.play_button_sound()
	get_tree().paused = false
	SceneChanger.goto_scene(get_tree().current_scene.scene_file_path)


func _on_main_menu_button_pressed() -> void:
	AudioManager.play_button_sound()
	get_tree().paused = false
	SceneChanger.goto_main_menu()
