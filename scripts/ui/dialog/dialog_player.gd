extends Node2D

class_name DialogPlayer

signal dialog_finished

@export_group("Dialog Data")
@export var dialog_display: DialogDisplay
@export var start_wait_time: float = 2.0
@export var load_level_after: String = "res://levels/level_main_menu.tscn"
@export var animation_player: AnimationPlayer
@export var animation_player2: AnimationPlayer
@export_file("*.json") var dialog_text_file: String
@export var wait_for_input: bool = false
@export var pause_player_movement: bool = false

@onready var timer = $Timer
@onready var load_level_timer = $LoadLevelTimer

var dialogs_data: Array = []
var dialog_index: int = 0
var _player_was_paused: bool = false

func _ready() -> void:
	parse_json()
	timer.wait_time = start_wait_time
	if dialog_display:
		dialog_display.message_displayed.connect(next_message)
		dialog_display.dialog_finished.connect(handle_dialog_finished)
		dialog_display.wait_for_input = wait_for_input
	else:
		push_error("Dialog display not set in DialogPlayer")

	if dialogs_data.size() > 0:
		timer.start()

func _input(event: InputEvent) -> void:
	if not dialog_display or not dialog_display.dialog_playing:
		return
		
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("skip_dialog_text"):
		if dialog_display.dialog_writing:
			dialog_display.finish_writing()
		else:
			next_message()

func parse_json() -> void:
	if dialog_text_file == "":
		return
		
	dialog_index = 0
	var file_content = load_dialog_text()
	if file_content == "":
		return
		
	var json = JSON.new()
	var error = json.parse(file_content)
	var dialog_data_json : Dictionary

	if error != OK:
		push_error("Error parsing JSON: ", json.get_error_message())
	else:
		dialog_data_json = json.get_data()
		if dialog_data_json.has("dialogs"):
			dialogs_data = dialog_data_json["dialogs"]

func load_dialog_text() -> String:
	if not FileAccess.file_exists(dialog_text_file):
		push_error("Dialog file does not exist: ", dialog_text_file)
		return ""
	var file = FileAccess.open(dialog_text_file, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	return content

func next_message() -> void:
	if dialog_index < dialogs_data.size():
		_pause_player()
		dialog_display.display_next_message(dialogs_data[dialog_index])
		if dialogs_data[dialog_index].has("animation") and animation_player != null:
			if animation_player.has_animation(dialogs_data[dialog_index]["animation"]):
				animation_player.play(dialogs_data[dialog_index]["animation"])
		if dialogs_data[dialog_index].has("animation2") and animation_player2 != null:
			if animation_player2.has_animation(dialogs_data[dialog_index]["animation2"]):
				animation_player2.play(dialogs_data[dialog_index]["animation2"])
		dialog_index += 1
	elif dialog_index == dialogs_data.size():
		_unpause_player()
		dialog_finished.emit()
		if dialog_display.hide_dialog_after:
			dialog_display.hide_dialog()
		change_to_next_scene()
		dialog_index += 1

func _on_timer_timeout() -> void:
	next_message()

func handle_dialog_finished() -> void:
	load_level_timer.start()

func _on_load_level_timer_timeout() -> void:
	change_to_next_scene()

func change_to_next_scene() -> void:
	if load_level_after != "":
		if load_level_after == "res://levels/level_1.tscn":
			SceneChanger.goto_boss_battle()
		elif load_level_after == "res://levels/level_main_menu.tscn":
			SceneChanger.goto_main_menu()
		elif load_level_after == "res://levels/cutscene/intro_scene.tscn":
			SceneChanger.goto_intro()
		elif load_level_after == "res://levels/cutscene/outro_scene.tscn":
			SceneChanger.goto_outro()
		elif load_level_after == "res://levels/level_credits.tscn":
			SceneChanger.goto_credits()
		else:
			SceneChanger.goto_scene(load_level_after)


func _pause_player() -> void:
	if not pause_player_movement or _player_was_paused:
		return
	var player = Global.player
	if player and player.has_node("LimboHSM"):
		player.velocity = Vector2.ZERO
		player.get_node("LimboHSM").set_active(false)
		if player.has_node("AnimationPlayer"):
			player.get_node("AnimationPlayer").play("idle")
		_player_was_paused = true


func _unpause_player() -> void:
	if not _player_was_paused:
		return
	var player = Global.player
	if player and player.has_node("LimboHSM"):
		player.get_node("LimboHSM").set_active(true)
		_player_was_paused = false
