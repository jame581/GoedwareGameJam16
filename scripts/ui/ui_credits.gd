extends Control

@export var hide_back_button: bool = false
@export var title_label: String = "Thanks for playing!"

@onready var title_label_node: Label = %TitleLabel
@onready var back_button: Button = %BackButton

func _ready() -> void:
	title_label_node.text = title_label
	back_button.visible = not hide_back_button

func _on_back_button_pressed() -> void:
	AudioManager.play_button_sound()
	SceneChanger.goto_main_menu()
