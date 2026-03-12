extends CanvasLayer

var main_menu_path = "res://levels/level_main_menu.tscn"
var intro_path = "res://levels/cutscene/intro_scene.tscn"
var tutorial_path = "res://levels/level_tutorial.tscn"
var boss_battle_path = "res://levels/level_1.tscn"
var outro_path = "res://levels/cutscene/outro_scene.tscn"

@onready var animation_player = $AnimationPlayer

var current_scene: Node = null
var load_level: String = ""
var load_map_path: String = ""

func _ready() -> void:
	var root := get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	load_map_path = current_scene.scene_file_path
	visible = false

	# Connect the animation finished signal to the function
	animation_player.animation_finished.connect(_on_animation_finished)
	SignalBus.on_map_loaded.connect(_handle_map_loaded)

func goto_scene(map_name: String) -> void:
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.
	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:
	load_level = map_name

	animation_player.play("fade_in")

func restart_current_scene() -> void:
	animation_player.play("fade_in")

func goto_main_menu() -> void:
	goto_scene(main_menu_path)

func goto_intro() -> void:
	goto_scene(intro_path)

func goto_tutorial() -> void:
	goto_scene(tutorial_path)

func goto_boss_battle() -> void:
	goto_scene(boss_battle_path)

func goto_outro() -> void:
	goto_scene(outro_path)

func fade_in() -> void:
	animation_player.play("just_fade_in")

func fade_out() -> void:
	animation_player.play("just_fade_out")

func _deferred_goto_scene(path: String) -> void:
	# It is now safe to remove the current scene.
	current_scene.free()

	# Load the new scene.
	var s := ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instantiate()
	load_map_path = current_scene.scene_file_path

	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene
	SignalBus.on_map_loaded.emit(load_level)

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "fade_in":
		call_deferred("_deferred_goto_scene", load_level)
	elif anim_name == "just_fade_out":
		SignalBus.on_fade_out_finished.emit()
	elif anim_name == "just_fade_in":
		SignalBus.on_fade_in_finished.emit()

func _handle_map_loaded(_map_path: String) -> void:
	animation_player.play("fade_out")
