extends CanvasLayer

## Game HUD: displays player and boss health bars. Listens to SignalBus for decoupled updates.

@onready var health_bar: ProgressBar = %HealthBar
@onready var boss_health_bar: ProgressBar = %BossHealthBar

func _ready() -> void:
	SignalBus.player_health_changed.connect(_on_player_health_changed)
	SignalBus.boss_health_changed.connect(_on_boss_health_changed)
	SignalBus.boss_died.connect(_on_boss_died)


func _on_player_health_changed(current_hp: int, max_hp: int) -> void:
	health_bar.max_value = max_hp
	health_bar.value = current_hp
	_shake(health_bar)


func _on_boss_health_changed(current_hp: int, max_hp: int) -> void:
	boss_health_bar.max_value = max_hp
	boss_health_bar.value = current_hp
	_shake(boss_health_bar)


func _on_boss_died() -> void:
	boss_health_bar.visible = false


func _shake(bar: Control, intensity: float = 3.0, duration: float = 0.3) -> void:
	var original_pos := bar.position
	var tween := create_tween()
	var steps := 6
	var step_duration := duration / steps
	for i in steps:
		var offset := Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		tween.tween_property(bar, "position", original_pos + offset, step_duration)
	tween.tween_property(bar, "position", original_pos, step_duration)
