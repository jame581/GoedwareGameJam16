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

### Boss Phases

**Phase 1 (MVP — build this first)**
- Boss has one main attack pattern:
  1. **Demon Smash**: Boss glows bright (like a candle lighting up) → levitates upward → slams into the ground → shockwave spreads along the floor
  - Telegraph: glow effect (warns player to prepare)
  - Dodge window: player must jump or dash to avoid the shockwave
  - After slam, boss is briefly vulnerable (punish window)
- Between slams, boss slowly walks toward player (menacing, not fast)

**Phase 2 (add if time allows)**
- Demon Smash continues but faster
- New attack: **Demon Spawn** — boss raises hand, summons 1-2 small demons that chase the player
  - Demons are weak (1-2 hits to kill) but force the player to split attention
  - Spawns on a cooldown so it doesn't overwhelm

**Phase 3 (add if time allows)**
- Both attacks combined, faster pace
- Boss becomes more erratic — shorter telegraph windows
- Possible visual change: mother's human form flickers through the demon, hinting she's still in there

### Boss AI (LimboAI Behavior Tree)

```
Root (Selector)
├── Phase Check (current HP determines phase)
├── Phase 1 Branch
│   ├── Walk toward player
│   ├── If in range → Demon Smash sequence (glow → levitate → slam → recover)
│   └── Idle / reposition
├── Phase 2 Branch (if implemented)
│   ├── Demon Smash (shorter cooldown)
│   └── Spawn Demons (on timer)
└── Phase 3 Branch (if implemented)
    ├── Faster Demon Smash
    ├── Spawn Demons (more frequent)
    └── Rage mode (shorter recovery)
```

---

## Player — The Daughter (Samurai)

### Controls
| Action       | Description                                    |
|--------------|------------------------------------------------|
| Move         | Left/right movement                            |
| Jump         | Jump to avoid shockwaves, reach platforms       |
| Light Attack | Fast sword slash, low damage                   |
| Heavy Attack | Slow swing, high damage, use during punish windows |
| Dash         | Quick dodge, brief invincibility frames         |

> **Scope note**: Light attack + dash + jump is enough for MVP. Add heavy attack if time allows.

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

- [ ] Main menu (start button, that's it)
- [ ] Beginning cutscene (static images + text)
- [ ] NPC dialogue scene
- [ ] Arena scene with background
- [ ] Player: move, jump, light attack, dash
- [ ] Boss: walk + Demon Smash attack (glow → levitate → slam → shockwave)
- [ ] Boss HP bar
- [ ] Choice trigger at low HP
- [ ] Three ending screens
- [ ] Basic sound effects

## Stretch Goals (if time allows)

- [ ] Phase 2: Demon Spawn attack
- [ ] Phase 3: Combined + faster
- [ ] Heavy attack for player
- [ ] Mother's face flickering through demon in phase 3
- [ ] Animated cutscenes instead of static
- [ ] Music / ambient audio
- [ ] Screen shake, particles, juice

---

## Characters

| Character | Role        | Sprite        | Name    |
|-----------|-------------|---------------|---------|
| Daughter  | Player      | `samurai.png` | —       |
| Mother    | Boss        | `char1.png`   | Sanaki  |
| Father    | NPC (fallen)| (need sprite) | Hitoshi |
| NPC       | Village elder / warrior | (need sprite) | — |

> **Note**: Mother's sprite needs a "possessed" variant (glowing eyes, dark aura). Could be done with a shader overlay on the existing sprite. Father needs a wounded/fallen sprite visible in the arena background.
