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


func _on_boss_health_changed(current_hp: int, max_hp: int) -> void:
	boss_health_bar.max_value = max_hp
	boss_health_bar.value = current_hp


func _on_boss_died() -> void:
	boss_health_bar.visible = false
