extends PanelContainer

@onready var version_label: Label = %VersionLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var vbox_menu: VBoxContainer = $MarginContainer/HBoxContainer/VBoxMenu
@onready var settings_scroll: ScrollContainer = $MarginContainer/HBoxContainer/SettingsScroll
@onready var credits_box: VBoxContainer = %CreditsBox

@onready var controls_setting: GridContainer = %ControlSettingsGrid
@onready var controls_gamepad_setting: GridContainer = %ControlGamepadSettingsGrid
@onready var sound_toggle: CheckButton = %SoundsEnabledCheckButton

@onready var item_list: ItemList = $MarginContainer/HBoxContainer/VBoxDebugMenu/MenuOptions/ItemList

var hide_credits = false
var hide_settings = false


var input_actions = {
	"left": " Move Left",
	"right": "Move Right",
	"jump": "Jump",
	"interact": "Interact",
	"pause_game": "Pause Game",
	"skip_dialog_text": "Skip Dialog Text"
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize()
	sound_toggle.button_pressed = AudioManager.audio_enabled

func initialize() -> void:
	hide_all_settings()
	version_label.text = "Version: " + Global.get_game_version()

	create_action_list()

func _on_start_game_button_pressed() -> void:
	AudioManager.play_button_sound()
	SceneChanger.goto_scene("res://levels/Level_1.tscn")

func _on_quit_button_pressed() -> void:
	AudioManager.play_button_sound()
	get_tree().quit()

func _on_animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == "show_credits" and hide_credits:
		credits_box.hide()
		vbox_menu.show()

	if anim_name == "show_settings" and hide_settings:
		settings_scroll.hide()
		vbox_menu.show()

func _on_options_button_pressed() -> void:
	AudioManager.play_button_sound()
	if settings_scroll.visible:
		animation_player.play("show_settings", -1, -2.0, true)
		hide_settings = true
	else:
		hide_all_settings()
		vbox_menu.hide()
		settings_scroll.show()
		hide_settings = false
		animation_player.play("show_settings")

func _on_credits_button_pressed() -> void:
	AudioManager.play_button_sound()
	if credits_box.visible:
		animation_player.play("show_credits", -1, -4.0, true)
		hide_credits = true
	else:
		hide_all_settings()
		vbox_menu.hide()
		credits_box.show()
		hide_credits = false
		animation_player.play("show_credits")

func _on_sounds_enabled_check_button_toggled(button_pressed: bool) -> void:
	if button_pressed:
		AudioManager.set_sound_enabled(true)
	else:
		AudioManager.set_sound_enabled(false)

func hide_all_settings() -> void:
	settings_scroll.hide()
	credits_box.hide()
	vbox_menu.show()

func create_action_list() -> void:
	InputMap.load_from_project_settings()
	clear_action_list()

	for action in input_actions:
		var action_label: Label = Label.new()
		action_label.text = input_actions[action]
		action_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var input_label: Label = Label.new()
		input_label.size_flags_horizontal = Control.SIZE_SHRINK_END & Control.SIZE_EXPAND_FILL

		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			for event in events:
				if event is InputEventKey:
					input_label.text += event.as_text().trim_suffix(" (Physical)") + " / "
			input_label.text = input_label.text.trim_suffix(" / ")
		else:
			input_label.text = "Not set"

		controls_setting.add_child(action_label)
		controls_setting.add_child(input_label)

	for action in input_actions:
		var action_label: Label = Label.new()
		action_label.text = input_actions[action]
		action_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var input_label: Label = Label.new()
		input_label.size_flags_horizontal = Control.SIZE_SHRINK_END & Control.SIZE_EXPAND_FILL
		input_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		input_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			for event in events:
				if event is InputEventJoypadButton or event is InputEventJoypadMotion:
					input_label.text += get_short_event_name(event) + " / "
			input_label.text = input_label.text.trim_suffix(" / ")
		else:
			input_label.text = "Not set"

		controls_gamepad_setting.add_child(action_label)
		controls_gamepad_setting.add_child(input_label)

func get_short_event_name(event: InputEvent) -> String:
	if event is InputEventJoypadButton:
		return "Button " + str(event.button_index)
	elif event is InputEventJoypadMotion:
		return "Axis " + str(event.axis)
	return ""

func clear_action_list() -> void:
	for item in controls_setting.get_children():
		item.queue_free()

	for item in controls_gamepad_setting.get_children():
		item.queue_free()


func _on_start_selected_level_button_pressed() -> void:
	if item_list.get_selected_items().size() > 0:
		var item = item_list.get_selected_items()[0]
		var level_name = item_list.get_item_text(item)
		SceneChanger.goto_scene("res://levels/" + level_name + ".tscn")
