extends Control

## Pause menu: toggled by "pause" input action. Pauses the game tree while visible.

@onready var game_over_menu: Control = %GameOverMenu

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	visible = false
	mouse_filter = MOUSE_FILTER_IGNORE


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if game_over_menu and game_over_menu.visible:
			return
		if visible:
			_resume()
		else:
			_pause()
		get_viewport().set_input_as_handled()


func _pause() -> void:
	visible = true
	mouse_filter = MOUSE_FILTER_STOP
	get_tree().paused = true


func _resume() -> void:
	visible = false
	mouse_filter = MOUSE_FILTER_IGNORE
	get_tree().paused = false


func _on_resume_button_pressed() -> void:
	AudioManager.play_button_sound()
	_resume()


func _on_restart_button_pressed() -> void:
	AudioManager.play_button_sound()
	get_tree().paused = false
	SceneChanger.goto_scene(get_tree().current_scene.scene_file_path)


func _on_main_menu_button_pressed() -> void:
	AudioManager.play_button_sound()
	get_tree().paused = false
	SceneChanger.goto_main_menu()
