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

# Health events
@warning_ignore("unused_signal")
signal player_health_changed(current_hp: int, max_hp: int)
@warning_ignore("unused_signal")
signal player_died
@warning_ignore("unused_signal")
signal boss_health_changed(current_hp: int, max_hp: int)
@warning_ignore("unused_signal")
signal boss_activated
@warning_ignore("unused_signal")
signal boss_died
@warning_ignore("unused_signal")
signal boss_staggered
@warning_ignore("unused_signal")
signal ending_triggered(ending_type: String)
@warning_ignore("unused_signal")
signal spare_timer_updated(time_left: float)
