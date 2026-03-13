extends Panel

@onready var version_label: Label = %VersionLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var credits_box: Control = %CreditsBox

@onready var quit_button: Button = %QuitButton

var hide_credits = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	version_label.text = "Version: " + Global.get_game_version()
	if OS.has_feature("web"):
		quit_button.hide()


func _on_quit_button_pressed() -> void:
	AudioManager.play_button_sound()
	get_tree().quit()


func _on_credits_button_pressed() -> void:
	AudioManager.play_button_sound()
	if credits_box.visible:
		animation_player.play("hide_credits")
	else:
		animation_player.play("show_credits")


func _on_start_button_pressed() -> void:
	AudioManager.play_button_sound()
	SceneChanger.goto_boss_battle()
