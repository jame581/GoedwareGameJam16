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
- Single flat arena, village background (burning cottages, dark sky)
- Father (Hitoshi) is visible in the background — fallen, wounded, as emotional motivation
- Simple ground with maybe one raised platform

### Boss Stats
- **HP**: 100
- **Move speed**: 60
- **Shockwave projectile speed**: 200
- **Phase 2 threshold**: 50% HP

### Boss Phases

Phase transitions are handled by updating blackboard variables (timings + `spawn_enabled` flag) when HP crosses 50%. A single parameterized behavior tree handles both phases.

**Phase 1 (Implemented)**
- Boss has one main attack pattern:
  1. **Demon Smash**: Boss glows bright (0.8s telegraph) → levitates upward → slams into the ground → shockwave spreads L+R along the floor
  - Telegraph: glow effect with sprite tint (warns player to prepare)
  - Dodge window: player must jump or dash to avoid the shockwave
  - After slam, boss is vulnerable for 2.0s (punish window) — only time damage registers
  - Smash cooldown: 2.0s between attacks
- Between slams, boss slowly walks toward player (speed 60, menacing, not fast)
- Boss only takes damage during the vulnerable window (`is_exposed` flag)

**Phase 2 (Implemented — activates at 50% HP)**
- Demon Smash continues but faster: glow telegraph shortened to 0.5s, vulnerable window shortened to 1.2s
- New attack: **Demon Spawn** — boss summons 1-2 small demons that chase the player
  - Demons are weak (1-2 hits to kill) but force the player to split attention
  - Spawns on a 10s cooldown so it doesn't overwhelm

**Phase 3 (stretch goal)**
- Both attacks combined, faster pace
- Boss becomes more erratic — shorter telegraph windows
- Possible visual change: mother's human form flickers through the demon, hinting she's still in there

### Boss AI (LimboAI Behavior Tree)

Single parameterized tree at `ai/trees/witch_boss.tres`. Phase transitions update blackboard variables instead of switching branches.

```
ROOT (Selector)
├── DEMON SMASH (Sequence)
│   ├── IsSmashReady           — checks cooldown timer on blackboard
│   ├── CheckDistance < 120    — reuses ai/tasks/check_distance.gd
│   ├── FaceTarget             — flip sprite toward player
│   ├── GlowTelegraph          — tint sprite, wait glow_duration (0.8s P1 / 0.5s P2)
│   ├── Levitate               — rise upward over 0.5s
│   ├── SlamDown               — rapid descent to floor
│   ├── SpawnShockwaves        — instantiate L+R shockwave projectiles
│   ├── VulnerableWindow       — exposed for vulnerable_duration (2.0s P1 / 1.2s P2)
│   └── ResetAfterSlam         — reset cooldown, clear exposed flag
│
├── DEMON SPAWN (Sequence)     — only runs in Phase 2
│   ├── CheckBlackboardVar     — spawn_enabled == true
│   ├── IsSpawnReady           — checks spawn cooldown timer
│   ├── FaceTarget
│   ├── SpawnDemons            — instantiate 1-2 mob enemies
│   └── ResetSpawnCooldown
│
├── PURSUE (Sequence)          — walk toward player when no attack ready
│   ├── FaceTarget
│   └── Pursue                 — reuses ai/tasks/pursue.gd, approach_distance=80
│
└── BTWait 0.1                 — fallback idle tick
```

### Blackboard Variables
| Variable | Type | P1 Default | P2 Value | Description |
|----------|------|------------|----------|-------------|
| `target` | Node2D | Global.player | — | Player reference |
| `speed` | float | 60.0 | 60.0 | Walk speed |
| `smash_cooldown_timer` | float | 2.0 | — | Counts down each frame |
| `spawn_cooldown_timer` | float | 10.0 | — | Counts down each frame |
| `glow_duration` | float | 0.8 | 0.5 | Telegraph warning time |
| `vulnerable_duration` | float | 2.0 | 1.2 | Punish window time |
| `spawn_enabled` | bool | false | true | Gates demon spawn branch |

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

## The Choice Moment

When the boss reaches critical HP (~10%), the fight pauses. The demon staggers. The mother's human face flickers through.

Three options appear:

### Ending 1 — Kill the Boss → Save Father
- Player delivers the final blow
- The demon is destroyed — but so is the mother (Sanaki)
- Father (Hitoshi) is saved, daughter and father embrace over the loss
- Bittersweet: the family survives, but broken

### Ending 2 — Spare the Boss → Save Mother, Father Dies
- Player drops their weapon / walks away
- The demon remains, but the mother regains partial control
- However, the curse fully claims the father — Hitoshi fades away
- Mother is saved but at a terrible price

### Ending 3 — Sacrifice (Secret Ending)
- Player offers themselves to the demon
- The daughter's life force breaks the curse — mother is freed, father is saved
- But the daughter is gone
- The most emotional ending — both parents survive, but lose their child

### How to Trigger Endings
- **Kill**: Keep attacking when boss is staggered → ending 1
- **Spare**: Don't attack for X seconds during stagger → ending 2
- **Sacrifice**: Interact with the cursed stone during stagger → ending 3

> The sacrifice ending should feel hidden — the cursed stone appears on the ground during the stagger, and interacting with it triggers the secret ending. Players who are curious or observant find it.

---

## Ending Cutscenes

Same style as beginning cutscene — static frames with text. One scene per ending. Keep it short and emotional.

---

## Art & Atmosphere (Grimm Brothers Inspiration)

- Dark, muted colors — browns, deep greens, muted reds
- Fog, twisted trees, old wooden village
- Candlelight / firelight as the main light source
- Boss glow effect contrasts against the dark (demonic orange/red)
- Simple pixel art, keep consistent with existing character sprites

---

## Audio Notes (if time)
- Dark ambient / folk music for the fight
- Heartbeat or breathing sound during the choice moment
- Silence or soft music for endings

---

## MVP Checklist (Minimum Shippable Game)

- [x] Main menu (start button, that's it)
- [x] Beginning cutscene (static images + text)
- [x] NPC dialogue scene
- [ ] Arena scene with background
- [x] Player: move, jump, light attack, dash
- [x] Boss: walk + Demon Smash attack (glow → levitate → slam → shockwave)
- [x] Health/damage system (HealthComponent, HitboxComponent, HurtboxComponent)
- [ ] Boss HP bar (SignalBus signals ready: `boss_health_changed`, `boss_died`)
- [ ] Player HP bar (SignalBus signals ready: `player_health_changed`, `player_died`)
- [ ] Choice trigger at low HP
- [ ] Three ending screens
- [ ] Basic sound effects

## Stretch Goals (if time allows)

- [x] Phase 2: Demon Spawn attack (implemented, activates at 50% HP)
- [ ] Phase 3: Combined + faster
- [x] Heavy attack for player (3 damage, 1.1s animation)
- [ ] Mother's face flickering through demon in phase 3
- [ ] Animated cutscenes instead of static
- [ ] Music / ambient audio
- [ ] Screen shake, particles, juice

---

## Characters

| Character | Role        | Sprites | Name    |
|-----------|-------------|---------|---------|
| Daughter  | Player      | `assets/sprites/player/` (idle, run, jump, dash, sword_attack, sword_stab) | —       |
| Mother    | Boss (Witch)| `assets/sprites/witch/` (IDLE, MOVE, ATTACK, HURT, DEATH — 6 frames each) | Sanaki  |
| Father    | NPC (fallen)| (need sprite) | Hitoshi |
| NPC       | Village elder / warrior | (need sprite) | — |

> **Note**: Mother's sprite needs a "possessed" variant (glowing eyes, dark aura). Could be done with a shader overlay on the existing sprite. Father needs a wounded/fallen sprite visible in the arena background.
