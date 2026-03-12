extends Control

func _on_back_button_pressed() -> void:
	AudioManager.play_button_sound()
	SceneChanger.goto_main_menu()
