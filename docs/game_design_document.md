# Game Design Document
## GoedWare Game Jam #16 — "You Can't Save Them All"
**Engine**: Godot 4.6 | **AI Plugin**: LimboAI | **View**: Side-view 2D

---

## Story

A warrior village hidden in the mountains. One day, a stranger arrives. When he leaves, something remains — a **cursed stone**. After that, things change. People grow quiet. The nights grow longer.

The **Mother (Sanaki)** finds the stone — and is consumed by it. She transforms into something inhuman. She runs into the dark.

The **Father (Hitoshi)** takes his sword and goes after her. He tells the **Daughter** to stay. He doesn't return.

The Daughter can't wait any longer. She takes her blade and goes after them both.

At the village edge, an **NPC** warns her: Sanaki is gone, Hitoshi has fallen. Run. But the Daughter won't run.

She must face her possessed mother to save her family. But she can't save them all.

---

## Game Flow

```
Main Menu → Beginning Cutscene → NPC Dialogue → Boss Fight (Main Level) → Ending Cutscene
```

---

## Beginning Cutscene

Meru's intro text — narrated by the Daughter, shown as static frames with text:

1. "Our village lies hidden in the mountains. A village of warriors."
2. "One day, a stranger came. When he left, something remained. A stone."
3. "After that, things changed. People grew quiet. The nights grew longer."
4. "And my mother... different."
5. "That night, she ran into the dark. I remember her eyes."
6. "And the moment my father took his sword. 'Stay here,' he said."
7. "Then he disappeared into the night. I waited. An hour."
8. "The wind still carries sounds from the village. My father hasn't returned."
9. "So now... I'm going after them."

> **Scope note**: Static pixel art frames with text overlays. ~9 beats, can be condensed to 4-5 frames if needed.

---

## NPC Dialogue (before boss fight)

Short exchange at the village edge, before the player enters the arena:

- **NPC**: "Stop! Don't go any further."
- **NPC**: "Sanaki... she's gone. Whatever she became, it isn't your mother anymore."
- **NPC**: "Hitoshi tried to stop her."
- **NPC**: "He's fallen."
- **NPC**: "You need to run. Leave this place while you still can."

Player proceeds anyway → boss fight begins.

---

## Boss Fight — The Possessed Mother (Sanaki)

### Arena
- Arena with platforms/obstacles at varying heights
- Father (Hitoshi) is visible in the background — fallen, wounded, as emotional motivation
- Cursed stone pre-placed in the arena (hidden until stagger phase)

### Boss Stats
- **HP**: 100
- **Move speed**: 60
- **Shockwave projectile speed**: 200
- **Hover Y**: -60 (boss flies above terrain)
- **Ground Y**: 76 (ground level for slam landing)

### Boss Movement (Implemented)
The boss is a flying witch — she hovers at a fixed height (`hover_y`) above terrain and does not use gravity during normal combat. This prevents her from getting stuck on obstacles.
- **Pursue**: Boss flies toward player at hover height, smoothly lerping Y position
- **Collision**: `collision_mask = 0` during flight (ignores terrain), temporarily set to 1 during slam for obstacle detection
- **Slam landing**: Boss lands on whichever comes first — `ground_y` or an obstacle above it. Shockwaves spawn at actual landing position.

### Boss Phases

Phase 2 and 3 are disabled. Only Phase 1 is active with tuned timings.

**Phase 1 (Active)**
- Boss has one main attack pattern:
  1. **Demon Smash**: Boss glows bright (0.8s telegraph) → levitates upward from hover height → slams to ground → shockwave spreads L+R along the floor → returns to hover
  - Telegraph: glow effect with sprite tint (warns player to prepare)
  - Dodge window: player must jump or dash to avoid the shockwave
  - After slam, boss is vulnerable for 2.5s (punish window) — only time damage registers
  - Vulnerable state signaled by green hit shader effect
  - Smash cooldown: 1.5s between attacks
- Between slams, boss flies toward player at hover height (speed 60, menacing, not fast)
- Boss only takes damage during the vulnerable window (`is_exposed` flag)
- **Below 50% HP**: Each slam spawns a second shockwave wave after a configurable delay (default 1.5s)

**Phase 2 (Disabled — `phase2_threshold = 0.0`)**
- Code exists but never triggers. Demon Spawn and faster timings remain dormant.

**Phase 3 (Not implemented)**
- Stretch goal, not active.

### Stagger & Ending Choice (Implemented)

When the boss reaches 10% HP (`stagger_threshold = 0.1`):
- Boss enters **stagger state**: stops attacking, falls to ground with gravity, plays "stage" animation
- Orange hit shader effect signals stagger state
- Boss remains `is_exposed = true` — player can still hit her
- **10-second countdown timer** appears on HUD — timer never resets, runs continuously
- **Cursed stone** becomes visible and interactive (blue shader glow)
- BT stagger branch (highest priority) keeps boss idle indefinitely

Three endings triggered from stagger:
- **Kill**: Keep attacking until boss HP reaches 0 → "death" animation plays → `goto_save_father_ending()`
- **Spare**: Don't kill boss within 10 seconds → timer reaches 0 → `goto_save_mother_ending()`
- **Sacrifice**: Walk to cursed stone, press E (interact) → `goto_save_both_ending()`

### Boss AI (LimboAI Behavior Tree)

Single parameterized tree at `ai/trees/witch_boss.tres`.

```
ROOT (Selector)
├── STAGGER (Sequence)            — highest priority, active at ≤10% HP
│   ├── IsStaggered               — checks is_staggered blackboard var
│   └── BTWait 999                — do nothing forever
│
├── DEMON SMASH (Sequence)
│   ├── IsSmashReady              — checks cooldown timer on blackboard
│   ├── CheckDistance < 150       — reuses ai/tasks/check_distance.gd
│   ├── FaceTarget                — flip sprite toward player
│   ├── GlowTelegraph             — tint sprite, wait glow_duration (0.8s)
│   ├── Levitate                  — rise upward from hover height
│   ├── SlamDown                  — rapid descent to ground_y or obstacle
│   ├── SpawnShockwaves           — instantiate L+R projectiles (+ 2nd wave below 50% HP)
│   ├── VulnerableWindow          — exposed for vulnerable_duration (2.5s), green shader
│   ├── ResetAfterSlam            — reset cooldown, clear exposed flag
│   └── ReturnToHover             — lerp back to hover_y
│
├── DEMON SPAWN (Sequence)        — disabled (spawn_enabled stays false)
│   ├── CheckBlackboardVar        — spawn_enabled == true
│   ├── IsSpawnReady
│   ├── FaceTarget
│   ├── SpawnDemons
│   └── ResetSpawnCooldown
│
├── PURSUE (Sequence)             — fly toward player when no attack ready
│   ├── FaceTarget
│   └── Pursue                    — approach_distance=80, hover_y_var=hover_y
│
└── BTWait 0.1                    — fallback idle tick
```

### Blackboard Variables
| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `target` | Node2D | Global.player | Player reference |
| `speed` | float | 60.0 | Fly speed |
| `smash_cooldown_timer` | float | 0.0 | Counts down each frame |
| `spawn_cooldown_timer` | float | 10.0 | Counts down each frame |
| `glow_duration` | float | 0.8 | Telegraph warning time |
| `vulnerable_duration` | float | 2.5 | Punish window time |
| `spawn_enabled` | bool | false | Gates demon spawn branch (always false) |
| `hover_y` | float | -60.0 | Y position when flying |
| `ground_y` | float | 76.0 | Y position of ground level |
| `is_staggered` | bool | false | Gates stagger branch |

### Visual Feedback (Shader Effects)
The boss uses `hit_effect.gdshader` with different colors for different states:
| State | Color | Effect |
|-------|-------|--------|
| Hit (damage taken) | Red | Brief flash (0.3s), shake intensity 2.0 |
| Vulnerable window | Green | Sustained glow, shake intensity 1.0, flash speed 15 |
| Stagger | Orange | Sustained glow, shake intensity 1.5, flash speed 10 |

### Boss Animations
| Name | Usage |
|------|-------|
| `idle` | Default state, after slam reset |
| `move` | During pursue/movement |
| `charge` | During glow telegraph |
| `smash` | During slam down |
| `stage` | During stagger phase |
| `death` | When boss is killed |

---

## Player — The Daughter (Samurai)

### Stats
- **HP**: 5
- **Move speed**: 250
- **Jump velocity**: 400
- **Invincibility frames**: 0.8s after being hit

### Controls (Implemented)
| Action       | Input              | Description                                    |
|--------------|--------------------|------------------------------------------------|
| Move         | A/D, Left/Right    | Left/right movement                            |
| Jump         | W, Up, Space       | Jump to avoid shockwaves, reach platforms       |
| Light Attack | light_attack       | Fast sword slash, 1 damage (0.6s animation)    |
| Heavy Attack | heavy_attack       | Slow swing, 3 damage (1.1s animation), roots player |
| Dash         | dash               | Quick dodge, brief invincibility frames         |
| Interact     | E                  | Interact with cursed stone during stagger       |

### State Machine (LimboAI HSM)
Player uses LimboHSM with states: Idle, Move, Jump, Fall, Dash, LightAttack, HeavyAttack. Attack states enable the player's HitboxComponent for the duration of the attack animation.

---

## Combat System (Implemented)

### Components
Three reusable components in `scripts/components/` that can be attached to any entity:

| Component | Type | Purpose |
|-----------|------|---------|
| **HealthComponent** | Node | Tracks HP, handles damage/healing, emits `health_changed`/`damage_taken`/`died` signals. Supports invincibility frames. |
| **HitboxComponent** | Area2D | Deals damage. Disabled by default, enabled during attacks. Detects HurtboxComponents via collision mask. One-hit-per-activation prevents multi-hits. |
| **HurtboxComponent** | Area2D | Receives hits. Auto-routes damage to HealthComponent if assigned, or emits `hurt` signal for custom handling (e.g. boss `is_exposed` check). |

### Collision Layers
| Layer | Bit | Purpose |
|-------|-----|---------|
| 1 | 1 | Player body |
| 3 | 4 | Enemy body |
| 5 | 16 | Player hurtbox — enemy attacks detect this |
| 6 | 32 | Enemy hurtbox — player attacks detect this |

### Damage Flow

**Player → Boss**: Attack state enables HitBox (mask=32) → overlaps boss HurtBox (layer=32) → boss checks `is_exposed` → if vulnerable, routes to HealthComponent.

**Boss → Player**: Shockwave projectile (mask=16) → overlaps player HurtBox (layer=16) → HurtBox auto-routes to HealthComponent → i-frames prevent rapid multi-hits (0.8s).

### Entities Using Components
| Entity | HP | HitBox | HurtBox | Notes |
|--------|----|--------|---------|-------|
| Player | 5 | Yes (mask=32, enabled during attacks) | Yes (layer=16, auto-routes to health) | 0.8s i-frames |
| Witch Boss | 100 | No (shockwaves are separate projectiles) | Yes (layer=32, manual damage via `is_exposed`) | No i-frames, only vulnerable after slam |
| Mob Enemy | — | No (uses detonate on contact) | — | BT-driven pursue + explode |
| Shockwave | — | Acts as hitbox (mask=16, area_entered) | — | Projectile, queue_free on hit |

---

## The Choice Moment (Implemented)

When the boss reaches critical HP (~10%), the fight pauses. The demon staggers and falls to the ground. An orange shader effect signals the stagger state. A 10-second countdown timer appears on the HUD.

Three options:

### Ending 1 — Kill the Boss → Save Father
- Player keeps attacking the staggered boss until HP reaches 0
- Boss plays death animation, then transitions to `ending_save_father.tscn`
- The demon is destroyed — but so is the mother (Sanaki)
- Father (Hitoshi) is saved, daughter and father embrace over the loss
- Bittersweet: the family survives, but broken

### Ending 2 — Spare the Boss → Save Mother, Father Dies
- Player does not kill the boss within 10 seconds
- Timer reaches 0, transitions to `ending_save_mother.tscn`
- The demon remains, but the mother regains partial control
- However, the curse fully claims the father — Hitoshi fades away
- Mother is saved but at a terrible price

### Ending 3 — Sacrifice (Secret Ending)
- Player walks to the cursed stone (pre-placed in arena, hidden until stagger)
- Cursed stone glows blue during stagger, press E to interact
- Transitions to `ending_save_both.tscn`
- The daughter's life force breaks the curse — mother is freed, father is saved
- But the daughter is gone
- The most emotional ending — both parents survive, but lose their child

### Implementation Details
- **Stagger triggers at 10% HP** via `_check_stagger()` in `witch_boss.gd`
- **BT stagger branch** (IsStaggered → BTWait 999) is highest priority in root selector
- **Boss falls to ground** with gravity re-enabled (`collision_mask = 1`)
- **Boss stays exposed** — vulnerable_window and reset_after_slam skip their cleanup when staggered
- **Spare timer** runs continuously (never resets on hit), emits `spare_timer_updated` signal for HUD
- **Cursed stone** (`scenes/objects/cursed_stone.tscn`) listens for `boss_staggered` signal to activate
- **Ending routing** in `game_level.gd` via `ending_triggered(type)` signal → SceneChanger methods

---

## Cursed Stone (Implemented)

Pre-placed in `level_1.tscn`. Hidden until boss stagger phase.

- **Scene**: `scenes/objects/cursed_stone.tscn` — Area2D with ShaderMaterial (hit_effect shader, blue flash)
- **Script**: `scripts/objects/cursed_stone.gd` — distance-based player detection, interact on E key
- **Activation**: Listens for `boss_staggered` signal → becomes visible, enables blue shader, enables interaction
- **Interaction**: Player presses E within `interact_distance` (default 30px) → emits `ending_triggered("sacrifice")`

---

## HUD (Implemented)

- **Player health bar**: Top-left, red fill, shakes on damage
- **Boss health bar**: Top-right, purple fill, shakes on damage, hidden on boss death
- **Spare timer label**: Top-center, shows countdown seconds during stagger phase, hidden by default
- **Pause menu**: ESC to toggle
- **Game over menu**: Shown on player death

---

## Ending Cutscenes

Same style as beginning cutscene — static frames with text. One scene per ending. Keep it short and emotional.

Ending scenes:
- `levels/ending_save_father.tscn` — Kill ending (save father)
- `levels/ending_save_mother.tscn` — Spare ending (save mother)
- `levels/ending_save_both.tscn` — Sacrifice ending (save both)
- `levels/ending_save_none.tscn` — (unused, available for future use)

---

## SignalBus Signals

| Signal | Parameters | Purpose |
|--------|------------|---------|
| `on_map_loaded` | map_name: String | New map loaded |
| `on_fade_out_finished` | — | Fade animation complete |
| `on_fade_in_finished` | — | Fade animation complete |
| `player_health_changed` | current_hp, max_hp | Update player HP bar |
| `player_died` | — | Player death |
| `boss_health_changed` | current_hp, max_hp | Update boss HP bar |
| `boss_activated` | — | Start boss BT after dialogue |
| `boss_died` | — | Boss HP reached 0 |
| `boss_staggered` | — | Boss entered stagger at 10% HP |
| `ending_triggered` | ending_type: String | Route to ending scene ("kill", "spare", "sacrifice") |
| `spare_timer_updated` | time_left: float | Update HUD countdown during stagger |

---

## Art & Atmosphere (Grimm Brothers Inspiration)

- Dark, muted colors — browns, deep greens, muted reds
- Fog, twisted trees, old wooden village
- Candlelight / firelight as the main light source
- Boss glow effect contrasts against the dark (demonic orange/red)
- Simple pixel art, keep consistent with existing character sprites

---

## Audio Notes
- Dark ambient / folk music for the fight
- Boss has charge and shockwave sound effects (`charge_sound`, `shockwave_sound` exports)
- Heartbeat or breathing sound during the choice moment
- Silence or soft music for endings

---

## MVP Checklist (Minimum Shippable Game)

- [x] Main menu (start button, that's it)
- [x] Beginning cutscene (static images + text)
- [x] NPC dialogue scene
- [x] Arena scene with background and obstacles
- [x] Player: move, jump, light attack, heavy attack, dash
- [x] Boss: fly + Demon Smash attack (glow → levitate → slam → shockwave → return to hover)
- [x] Health/damage system (HealthComponent, HitboxComponent, HurtboxComponent)
- [x] Boss HP bar
- [x] Player HP bar
- [x] Choice trigger at 10% HP (stagger → 10s timer → three endings)
- [x] Three ending screens
- [x] Basic sound effects (charge, shockwave)
- [x] Boss flying movement (hover above obstacles)
- [x] Double shockwave below 50% HP
- [x] Cursed stone interactable (secret sacrifice ending)
- [x] Visual feedback: green (vulnerable), orange (stagger), blue (cursed stone), red (hit)

## Stretch Goals (if time allows)

- [ ] Phase 2: Demon Spawn attack (code exists, disabled)
- [ ] Phase 3: Combined + faster
- [ ] Mother's face flickering through demon in phase 3
- [ ] Animated cutscenes instead of static
- [ ] More music / ambient audio
- [ ] Screen shake, particles, juice

---

## Characters

| Character | Role        | Sprites | Name    |
|-----------|-------------|---------|---------|
| Daughter  | Player      | `assets/sprites/player/` (idle, run, jump, dash, sword_attack, sword_stab) | —       |
| Mother    | Boss (Witch)| `assets/sprites/witch/` (IDLE, MOVE, ATTACK, CHARGE, SMASH, STAGE, DEATH — 6 frames each) | Sanaki  |
| Father    | NPC (fallen)| `assets/sprites/father_injured.png` | Hitoshi |
| NPC       | Village elder / warrior | (need sprite) | — |

> **Note**: Mother's sprite uses hit_effect shader for visual states (red=hit, green=vulnerable, orange=stagger). Father has a wounded/fallen sprite visible in the arena background.
