# Game Design Document
## GoedWare Game Jam #16 — "You Can't Save Them All"
**Engine**: Godot 4.6 | **AI Plugin**: LimboAI | **View**: Side-view 2D

---

## Story

Medieval village, Grimm brothers atmosphere — dark forest, wooden cottages, fog.

A small family: **Father**, **Mother**, and **Daughter**.

One night, a **shadowy figure** appears at the family's door and places a cursed object (a dark grimoire / cursed relic) on the doorstep. Father finds it, picks it up — and is instantly possessed by a demon. His eyes glow, his body twists. He becomes the **Boss**.

The Daughter must fight her own father to save her family. But she can't save them all.

---

## Game Flow

```
Main Menu → Beginning Cutscene → Boss Fight (Main Level) → Ending Cutscene
```

That's it. Four screens. Keep it tight.

---

## Beginning Cutscene

Simple sequence (can be still images with text, or minimal animation):

1. Night. A shadowy figure approaches the cottage, places a glowing object at the door, disappears into the dark
2. Father opens the door, sees the object, picks it up
3. Dark energy consumes him — he transforms, eyes glowing
4. Mother screams, tries to reach him
5. Daughter grabs her sword — the fight begins

> **Scope note**: This can be as simple as 3-5 static pixel art frames with text overlays. No need for full animation.

---

## Boss Fight — The Possessed Father

### Arena
- Single flat arena, village background (burning cottages, dark sky)
- Mother is visible in the background (tied/trapped/cowering) as emotional motivation
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
- Possible visual change: father's human form flickers through the demon, hinting he's still in there (emotional storytelling through gameplay)

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

When the boss reaches critical HP (~10%), the fight pauses. The demon staggers. The father's human face flickers through.

Three options appear:

### Ending 1 — Kill the Boss → Save Mother
- Player delivers the final blow
- The demon is destroyed — but so is the father
- Mother is saved, she and daughter embrace
- Bittersweet: the family survives, but broken

### Ending 2 — Spare the Boss → Save Father, Mother Dies
- Player drops their weapon / walks away
- The demon remains, but the father regains partial control
- However, the curse claims the mother instead — she fades away
- Father is saved but at a terrible price

### Ending 3 — Sacrifice (Secret Ending)
- Player offers themselves to the demon
- The daughter's life force breaks the curse — father is freed, mother is saved
- But the daughter is gone
- The most emotional ending — both parents survive, but lose their child

### How to Trigger Endings
- **Kill**: Keep attacking when boss is staggered → ending 1
- **Spare**: Don't attack for X seconds during stagger → ending 2
- **Sacrifice**: Interact with the cursed object/special prompt during stagger → ending 3

> The sacrifice ending should feel hidden — maybe the cursed relic appears on the ground during the stagger, and interacting with it triggers the secret ending. Players who are curious or observant find it.

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
- [ ] Father's face flickering through demon in phase 3
- [ ] Animated cutscenes instead of static
- [ ] Music / ambient audio
- [ ] Screen shake, particles, juice

---

## Characters

| Character | Role   | Sprite         |
|-----------|--------|----------------|
| Daughter  | Player | `samurai.png`  |
| Mother    | NPC    | (need sprite)  |
| Father    | Boss   | `char1.png`    |

> **Note**: Father's sprite may need a "possessed" variant (glowing eyes, dark aura). Could be done with a shader overlay on the existing sprite.
