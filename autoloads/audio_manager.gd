extends Node2D

@export_group("Audio Manager")
@export var audio_enabled: bool = true
@export var intro_audio: AudioStream
@export var main_menu: AudioStream
@export var outro_audio: AudioStream
@export var main_game: AudioStream

# @onready var audio_background: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var audio_buttons: AudioStreamPlayer2D = $AudioStreamButtons
@onready var audio_background: AudioStreamPlayer = $BackgroundMusic

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS # This will make sure that the pause menu is always updated
	audio_background.stream = main_menu


	if audio_enabled:
		audio_background.play()

func play_button_sound() -> void:
	if audio_enabled:
		audio_buttons.play()

func set_sound_enabled(enabled: bool) -> void:
	audio_enabled = enabled
	if audio_enabled:
		audio_background.play()
	else:
		audio_background.stop()

func play_music(stream: AudioStream) -> void:
	if !audio_enabled:
		return
	audio_background.stream = stream
	audio_background.play()

func stop_music() -> void:
	audio_background.stop()
	audio_background.stream = null

func _on_audio_stream_player_2d_finished() -> void:
	if audio_enabled:
		audio_background.play()
