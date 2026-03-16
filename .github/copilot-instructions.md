This is **"You Can't Save Them All"** — a Godot 4.6 / GDScript side-view 2D boss-fight game made for GoedWare Game Jam #16. Uses the **LimboAI** plugin for boss behavior (BT) and player states (HSM).

## Code Style
- snake_case for variables/functions, PascalCase for classes/enums, SCREAMING_SNAKE_CASE for constants.
- Use `@onready` for node refs accessed in `_ready()`. Prefer explicit typing where it aids clarity.
- Signal names start with `on_` prefix (e.g., `on_map_loaded`).

## Game Architecture
- **SignalBus** autoload handles all cross-system events (health, boss phases, endings). Never couple systems directly — always route through SignalBus.
- **Combat** uses three reusable components in `scripts/components/`: `HealthComponent`, `HitboxComponent` (Area2D, disabled by default), `HurtboxComponent` (Area2D).
- **Collision layers**: 1 = player body, 3 = enemy body, 5 = player hurtbox, 6 = enemy hurtbox.
- Boss only takes damage when `is_exposed = true` (after Demon Smash slam, 2.5s window). Stagger triggers at 10% HP.
- **Three endings**: Kill boss → save father (`ending_save_father.tscn`), spare boss → save mother (`ending_save_mother.tscn`), interact with cursed stone → sacrifice (`ending_save_both.tscn`). Routed via `ending_triggered(type)` signal.

## Project Structure
- `levels/` — level and ending scenes. `scenes/` — reusable scenes (characters, objects, ui). `scripts/` — mirrors scene layout. `assets/` — raw art/audio + `.import` sidecars. `ai/` — LimboAI behavior trees and tasks.

## Key Signals (SignalBus)
`boss_staggered`, `boss_died`, `ending_triggered(type)`, `boss_health_changed(hp, max)`, `player_health_changed(hp, max)`, `spare_timer_updated(time_left)`, `boss_activated`.

## Running Locally
- VS Code task **"Run Godot Project"** → opens editor. **"Run Game"** → quick test.
- Do not commit machine-specific paths or hardcoded absolute paths.
