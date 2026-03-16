# You Can't Save Them All (GoedWare Game Jam #16)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Godot 4.6](https://img.shields.io/badge/Godot-4.6-blue)](https://godotengine.org/)

A dark 2D boss-fight game built for **GoedWare Game Jam #16**. You play as the Daughter — a samurai who must face her own possessed mother to save her family. But you can't save them all.

## ⚡ Features

- **Three endings** — Kill, Spare, or Sacrifice. Each choice saves someone. None saves everyone.
- **Boss AI (LimboAI BT):** Possessed mother (Sanaki) hovers, telegraphs, and slams with shockwaves. Only vulnerable after each slam.
- **Player controller (LimboHSM):** Move, jump, dash, light attack, heavy attack — all state-machine driven.
- **Reusable combat components:** `HealthComponent`, `HitboxComponent`, `HurtboxComponent` — shared between player and boss.
- **Stagger & choice moment:** Boss staggers at 10% HP. A 10-second countdown forces your decision.
- **Cursed stone (secret ending):** Interact with the stone during stagger to unlock the sacrifice ending.

## 🎮 Controls

| Action       | Input                      |
|--------------|----------------------------|
| Move         | A / D or Left / Right      |
| Jump         | Space, W, or Up Arrow      |
| Light Attack | J or F                     |
| Heavy Attack | K or G                     |
| Dash         | Shift                      |
| Interact     | E                          |

## 🚀 Quick Start

### Prerequisites
- [Godot Engine 4.6](https://godotengine.org/download/) (GL Compatibility renderer)

### Running locally
1. Clone: `git clone <repository-url>`
2. Open Godot and import `project.godot`
3. Press **F5** to run (entry scene: `res://levels/level_main_menu.tscn`)

## 📁 Project Structure

```text
├── addons/limboai/  # LimboAI plugin (behavior trees + HSM)
├── ai/              # Boss behavior tree and custom BT tasks
├── assets/          # Sprites, sounds, fonts
├── autoloads/       # Global, SignalBus, SceneChanger, AudioManager
├── levels/          # Level and ending scenes
├── scenes/          # Reusable scenes (player, boss, UI, objects)
└── scripts/         # GDScript source, mirrors scene layout
```

## 📝 License

This project is licensed under the [MIT License](LICENSE).

## Screnshoots

![Main Menu](itch/screenshots/main_menu.png)
![Intro](itch/screenshots/intro.png)
![Gameplay 1](itch/screenshots/gameplay_1.png)
![Gameplay 2](itch/screenshots/gameplay_2.png)
