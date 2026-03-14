extends CanvasLayer

## Player HUD: displays health bar. Listens to SignalBus for decoupled updates.

@onready var health_bar: ProgressBar = %HealthBar

func _ready() -> void:
	SignalBus.player_health_changed.connect(_on_player_health_changed)


func _on_player_health_changed(current_hp: int, max_hp: int) -> void:
	health_bar.max_value = max_hp
	health_bar.value = current_hp
