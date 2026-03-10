extends Node

var player: CharacterBody2D

func register_player(p_player: CharacterBody2D) -> void:
	player = p_player

func get_game_version():
	return ProjectSettings.get_setting("application/config/version")
