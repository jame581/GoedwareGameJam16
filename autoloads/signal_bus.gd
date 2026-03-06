extends Node


# Map events

# called when new map is loaded
@warning_ignore("unused_signal")
signal on_map_loaded(map_name: String)

# SceneChanger
@warning_ignore("unused_signal")
signal on_fade_out_finished()

@warning_ignore("unused_signal")
signal on_fade_in_finished()
