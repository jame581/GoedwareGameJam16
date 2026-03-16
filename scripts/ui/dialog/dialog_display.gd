extends MarginContainer

class_name DialogDisplay

signal message_displayed()
signal dialog_finished()

@export var write_timer_duration: float = 0.05
@export var press_enter_visible: bool = true

@onready var dialog_text: RichTextLabel = $VBoxContainer/HBoxContainer/PanelText/MarginContainer/DialogText
@onready var dialog_image: TextureRect = $VBoxContainer/HBoxContainer/PanelScreen/AIScreenTexture
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var write_timer: Timer = $WriteTimer
@onready var wait_timer: Timer = $WaitTimer
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var press_to_continue: Label = $VBoxContainer/PressToContinueLabel

var portrait: Texture = null
var hide_dialog_after: bool = false
var dialog_writing: bool = false
var dialog_shown: bool = false
var dialog_playing: bool = false
var dialog_queue: Array = []
var wait_for_input: bool = false

func _ready() -> void:
	visible = false
	write_timer.wait_time = write_timer_duration
	press_to_continue.visible = press_enter_visible

func show_dialog(dialog_data: Dictionary) -> void:
	if dialog_playing:
		dialog_queue.append(dialog_data)
		return

	dialog_playing = true
	dialog_image.texture = null
	dialog_text.set_visible_characters(0)
	dialog_text.set_text(dialog_data["text"])
	wait_timer.wait_time = dialog_data["wait_time"] if dialog_data.has("wait_time") and dialog_data["wait_time"] > 0 else 2.0
	hide_dialog_after = dialog_data["hide_dialog_after"] if dialog_data.has("hide_dialog_after") else true
	_set_portrait(dialog_data["portrait"] if dialog_data.has("portrait") else "")

	if animation_player.has_animation("show_dialog"):
		animation_player.play("show_dialog")
	else:
		_on_animation_player_animation_finished("show_dialog")
	visible = true

func display_next_message(dialog_data: Dictionary) -> void:
	if dialog_shown:
		dialog_text.set_visible_characters(0)
		dialog_text.set_text(dialog_data["text"])
		wait_timer.wait_time = dialog_data["wait_time"] if dialog_data.has("wait_time") and dialog_data["wait_time"] > 0 else 2.0  
		hide_dialog_after = dialog_data["hide_dialog_after"] if dialog_data.has("hide_dialog_after") else true
		_set_portrait(dialog_data["portrait"] if dialog_data.has("portrait") else "")
		dialog_image.texture = portrait

		write_timer.start()
		dialog_writing = true
		if audio_player.stream != null and !audio_player.is_playing():
			audio_player.play()
	else:
		show_dialog(dialog_data)

func _set_portrait(portrait_path: String) -> void:
	if portrait_path != "":
		if ResourceLoader.exists(portrait_path):
			portrait = load(portrait_path) as Texture2D
		else:
			push_error("Portrait not found: ", portrait_path)
			portrait = null
	else:
		portrait = null

func hide_dialog() -> void:
	if not dialog_playing:
		return
		
	dialog_playing = false
	
	if animation_player.has_animation("hide_dialog"):
		animation_player.play("hide_dialog")
	else:
		_on_animation_player_animation_finished("hide_dialog")
	
	dialog_image.texture = null
	write_timer.stop()
	wait_timer.stop()
	audio_player.stop()
	dialog_shown = false
	dialog_finished.emit()

func _on_animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == "show_dialog":
		write_timer.start()
		dialog_writing = true
		dialog_image.texture = portrait
		dialog_shown = true
		if audio_player.stream != null and !audio_player.is_playing():
			audio_player.play()
	elif anim_name == "hide_dialog":
		dialog_writing = false
		dialog_shown = false
		check_next_message()

func check_next_message() -> void:
	if dialog_queue.size() > 0:
		show_dialog(dialog_queue.pop_front())
	else:
		dialog_playing = false

func _on_write_timer_timeout() -> void:
	dialog_text.visible_characters += 1
	if dialog_text.visible_characters >= dialog_text.get_total_character_count():
		write_timer.stop()
		dialog_writing = false
		audio_player.stop()
		if not wait_for_input:
			wait_timer.start()

func finish_writing() -> void:
	if not dialog_shown:
		return

	if dialog_writing:
		write_timer.stop()
		dialog_writing = false
		dialog_text.visible_characters = dialog_text.get_total_character_count()
		audio_player.stop()
		if not wait_for_input:
			wait_timer.start()
	elif !wait_timer.is_stopped():
		_on_wait_timer_timeout()

func _on_wait_timer_timeout() -> void:
	wait_timer.stop()
	audio_player.stop()
	message_displayed.emit()
	if hide_dialog_after:
		hide_dialog()
