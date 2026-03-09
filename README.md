# Godot-BossFightOhYeah (GoedWare Game Jam #16)

[![CI Status](https://github.com/hubacekjakub/Godot-QuickStart/actions/workflows/main.yml/badge.svg)](https://github.com/hubacekjakub/Godot-QuickStart/actions/workflows/main.yml)
[![Build Status](https://github.com/hubacekjakub/Godot-QuickStart/actions/workflows/main.yml/badge.svg)](https://github.com/hubacekjakub/Godot-QuickStart/actions/workflows/main.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Godot 4.6](https://img.shields.io/badge/Godot-4.6-blue)](https://godotengine.org/)

**Godot-BossFightOhYeah** is a 2D boss fight game prototype developed for the **GoedWare Game Jam #16**. 

Built with Godot 4.6, this project focuses on robust state machine-driven AI using the [LimboAI](https://github.com/limboai/limboai) plugin. It features a fully functioning player controller with platformer mechanics (jump, dash, movement) and a multi-phase boss enemy (Shockwave Boss) complete with telegraphing, approach states, bomb drops, and shockwave attacks.

## ⚡ Features

- **LimboAI Integration:** Both the player and boss utilize `LimboHSM` (Hierarchical State Machines) for clean, decoupled logic and scalable behaviors.
- **Boss Prototype:** Includes a multi-phase "Shockwave Boss" featuring:
  - Approach state
  - Bomb attack phase (spawning delayed explosive projectiles across the arena)
  - Shockwave attack phase (spawning ground-based waves)
  - Vulnerability phases
- **Player Controller:** Smooth 2D platforming logic with idle, move, jump, fall, and dash states.
- **Automated CI/CD:** Integrated GitHub Actions for automatic validation, multi-platform builds (Windows, Linux, Web), and itch.io deployment.
- **Main Menu UI:** Includes options, settings toggles (sounds, controls), and a level selector.

## 🚀 Quick Start

### Prerequisites
- [Godot Engine 4.6](https://godotengine.org/download/) or later (GL Compatibility renderer).

### Running the Game locally
1. **Clone** this repository: `git clone <repository-url>`
2. **Open** Godot Engine and import the `project.godot` file.
3. The main entry scene is configured to `res://levels/level_main_menu.tscn`.
4. Press **F5** (or click the Play button in the editor top right) to run the game.

**Controls:**
- **Move:** A/D or Left/Right Arrows
- **Jump:** Space or W or Up Arrow
- **Dash:** Shift

## 📁 Project Structure

```text
├── addons/limboai/  # LimboAI plugin for state machines and behavior trees
├── assets/          # Sprites, sounds, fonts, and textures
├── autoloads/       # Global singletons (Global, SignalBus, SceneChanger, AudioManager)
├── levels/          # Game levels and menus (Main Menu, Level 1, Playgrounds)
├── scenes/          # Reusable entity scenes (Player, Boss, Projectiles, UI)
└── scripts/         # GDScript source code (Strictly typed, organized by entity)
    ├── boss/        # Boss states and projectiles
    ├── player/      # Player states
    └── ui/          # UI logic
```

## 🤖 Automated Deployment

This project inherits a zero-config CI/CD pipeline.

### One-Command Release
```bash
git tag v1.0.0 && git push origin v1.0.0
# → Automatic build + GitHub release + itch.io deployment!
```

### Deployment Setup
Add these GitHub secrets for itch.io deployment:
- **`BUTLER_API_KEY`** - Get from your itch.io account settings.
- **`ITCH_USERNAME`** - Your itch.io username.
- **`ITCH_GAME_NAME`** - Your game project name.

## 📝 License

This project is licensed under the [MIT License](LICENSE).