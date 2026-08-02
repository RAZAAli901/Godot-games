# The Battle of Claude

Battlefield-style first-person shooter vs AI bots. **Godot 4.7.1** (GDScript,
Jolt physics). All four design phases from [BRIEF.md](BRIEF.md) are in — the
game is playable end to end (menu → 8v8 match → win/lose).

![status](https://img.shields.io/badge/status-playable-brightgreen)

---

## Getting started

### 1. Install the engine

Download **Godot 4.7.1 — Standard (GDScript) build** (not the .NET/C# build):

- https://godotengine.org/download/archive/4.7.1-stable/

It's a single portable `.exe` — no installer needed.

### 2. Play it (fastest)

**From the Godot editor**
1. Launch Godot, click **Import**.
2. Select `The-Battle-of-Claude/project.godot` and open it.
3. Press **F5** (or the ▶ Play button, top-right).

**From a terminal** (no editor UI)
```bash
"C:\path\to\Godot_v4.7.1-stable_win64.exe" --path "The-Battle-of-Claude"
```

Either way you boot into the main menu → **PLAY**.

### 3. Build a standalone .exe (optional)

A build needs the **export templates** for 4.7.1 (one-time, ~1 GB):

- In the editor: **Editor ▸ Manage Export Templates… ▸ Download and Install**.
- Then **Project ▸ Export…** already has a *Windows Desktop* preset — click
  **Export Project** → `build/TheBattleOfClaude.exe`.

Or entirely from the command line:
```bash
# once: templates must be installed (see above)
"C:\path\to\Godot_v4.7.1-stable_win64.exe" --headless --path "The-Battle-of-Claude" \
  --export-debug "Windows Desktop" build/TheBattleOfClaude.exe
```
The build writes `TheBattleOfClaude.exe` + `.pck` into `build/` (git-ignored).

---

## Controls

| Action | Key |
|---|---|
| Move | `W` `A` `S` `D` |
| Look | Mouse |
| Sprint | `Shift` (hold, moving forward) |
| Crouch | `Ctrl` (hold) |
| Jump | `Space` |
| Fire | Left Mouse |
| Aim (ADS) | Right Mouse |
| Reload | `R` |
| Switch weapon | `1` Primary · `2` Pistol · `3` Knife |
| Gunsmith | `G` |
| Enter / exit vehicle | `E` (stand near the jeep) |
| Minimap | `Tab` (hold) |
| Pause | `Esc` |

**Goal:** you spawn on the blue team in an 8v8 deathmatch — eliminate every red
bot to win. Press `G` to swap your primary and bolt on attachments before the fight.

---

## What's in it

| Phase | Delivered |
|---|---|
| 1 — Core FPS | Controller (move/look/sprint/crouch/jump/head-bob), greybox arena, HUD |
| 2 — Weapons | 7 weapons + 12 attachments, gunsmith with live stats, per-weapon SFX, real models |
| 3 — Combat | Navmesh AI bots, 8v8 match + win/lose, drivable jeep, world SFX |
| 4 — Polish | Main menu, settings, pause, tab minimap, map detail, postprocess |

**Not yet in** (needs login-gated assets — see [ASSETS_CREDITS.md](ASSETS_CREDITS.md)):
reload animations (Mixamo FPS-arm rig), real recorded gunshot SFX, a knife model.

---

## Tuning

Balance is data-driven — no code edits needed:

- **Weapon / attachment stats** — `resources/weapons/*.tres`, `resources/attachments/*.tres`
- **Team size (2–20), map size, mouse sensitivity** — `[game]` section of `project.godot`
  (also editable live in the in-game **Settings** menu)

---

## Layout

```
The-Battle-of-Claude/
├── project.godot              Engine config, input map, [game] tunables, GameState autoload
├── scenes/
│   ├── main.tscn              Match root: environment, sun, world, player, HUD, match, jeep
│   ├── player/player.tscn     CharacterBody3D FPS rig (camera, loadout mount)
│   ├── weapons/weapon.tscn    Generic data-driven weapon (mesh built from WeaponData)
│   ├── bot.tscn               AI combatant (NavigationAgent3D)
│   ├── vehicle.tscn           Drivable jeep (VehicleBody3D)
│   ├── world/                 terrain.tscn, target_dummy.tscn
│   └── ui/                    main_menu, settings, pause_menu, hud, gunsmith
├── scripts/                   One GDScript per system
├── resources/
│   ├── default_env.tres       WorldEnvironment
│   ├── weapons/*.tres         Per-weapon stats (WeaponData)
│   └── attachments/*.tres     Attachment modifiers (AttachmentData)
└── assets/models/blaster-kit/ Kenney Blaster Kit (CC0) weapon models
```
