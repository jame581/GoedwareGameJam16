extends Area2D

@export_file("*.json") var dialog_file: String = "res://resources/dialogs/tutorial_npc_dialog.json"
@export var dialog_player_path: NodePath
@export var pause_player: bool = false

var triggered: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if triggered:
		return
		
	if body.is_in_group("player"):
		var dialog_player = get_node_or_null(dialog_player_path)
		if dialog_player and dialog_player.has_method("parse_json"):
			triggered = true
			dialog_player.dialog_text_file = dialog_file
			dialog_player.pause_player_movement = pause_player
			dialog_player.parse_json()
			dialog_player.next_message()
		else:
			push_error("DialogPlayer not found or invalid at path: ", dialog_player_path)
