# The Battle of Claude — Project Brief for Claude Code

Paste this entire file to Claude Code as your starting instruction.

---

## ENVIRONMENT

Godot 4.7.1 (Standard, GDScript — not the .NET build) is installed at:

```
D:\godot\Godot_v4.7.1-stable_win64.exe
```

Use this path to run/test/export the project headlessly, e.g.:

```
"D:\godot\Godot_v4.7.1-stable_win64.exe" --headless --path <project_folder> --quit-after 10
```

and to export a runnable build:

```
"D:\godot\Godot_v4.7.1-stable_win64.exe" --headless --path <project_folder> --export-debug "Windows Desktop" build/game.exe
```

Confirm this executable runs correctly before starting Phase 1. If it fails, report the exact error rather than working around it silently.

---

## PROJECT OVERVIEW

**Title:** The Battle of Claude
**Type:** Battlefield-style FPS vs AI bots (single-player, bot-populated matches)
**Platform:** Compiled desktop game (Windows), not a web game
**Engine/Stack:** Godot 4.x, GDScript, Jolt physics, WorldEnvironment for PBR/SSAO/SSR/glow/volumetric fog

**Goal:** Playable FPS — realistic movement, full weapon roster with a gunsmith/attachment system, drivable vehicles, AI bot combat (start 8v8, scale toward 20v20 via config value), a large mountain-ruins terrain map, tab-toggle 2D minimap, sci-fi military main menu.

---

## ASSET SOURCING RULES

- You (the agent) may directly fetch/download assets yourself from: **Kenney.nl, Quaternius.com, OpenGameArt.org, Freesound.org, Pixabay Sound Effects** — these are script/CLI-downloadable, no login required. Use curl/wget, save into the project's `/assets` folder, and log the source URL + license in an `ASSETS_CREDITS.md` file as you go.
- You may **NOT** fetch from Sketchfab or Mixamo — these require a logged-in account and manual license click-through. For anything needed from those sources, list exactly what to search for and download; the user will place the file in `/assets/incoming` for import.
- Before importing ANY asset, confirm its license permits free use in a personal/portfolio project.

---

## WORKING RULES

- Break all work into small, frequent, incremental commits (git) — never one big commit per feature. Commit after every working sub-step (e.g. "add pistol raycast fire", "add reload state machine", "add ADS zoom").
- Build and run the actual exported build after each phase before moving on — don't stack unverified systems.
- Keep bot count, map size, and vehicle count as exported config values, not hardcoded, so they're tunable for performance later.
- Store all weapon/attachment stats as Godot `.tres` Resource files, never hardcoded directly in scripts, so balance can be tuned later without touching code.

Work through the 4 phases below **in order**. Do not start Phase 2 until Phase 1 is committed and running as an actual exported build. Same rule applies between all subsequent phases.

---

## PHASE 1 — Core FPS Foundation

- Godot project scaffold, Jolt physics enabled, WorldEnvironment set up for PBR/SSAO/glow baseline.
- First-person CharacterBody3D controller: WASD move, mouse look, sprint, crouch, jump, slide/lean if feasible, realistic accel/decel and head-bob (smooth, not floaty or twitchy).
- Greybox terrain (Godot HeightMapShape3D or sculpted mesh, large scale ~2km²) with one test weapon (AR): raycast hit detection, muzzle flash particle, recoil pattern that climbs and resets realistically (not linear/instant).
- Basic HUD: crosshair, ammo counter, health bar (Control nodes).
- Commit each sub-system separately.

## PHASE 2 — Full Weapon System + Gunsmith

- Weapon models for: AR, Pistol, Sniper Rifle, Shotgun, LMG, SMG, Knife (melee). Source from Kenney/Quaternius directly; flag any needed Sketchfab pieces for the user to download.
- Per-weapon stats: fire rate, damage falloff by range, recoil pattern, ADS speed, mag size, reload time, movement penalty — as `.tres` Resource files (see stat tables below).
- Reload animations: request Mixamo/Sketchfab FPS-arm rig files if needed; wire into an AnimationTree state machine (idle → reload → idle, fire-interrupt only where realistic).
- Gunsmith menu UI: attachment slots (optic, barrel, mag, grip, muzzle) per weapon, each modifying real stats. Loadout = Primary (AR/SMG/Shotgun/LMG/Sniper) + Pistol + Knife.
- Gunshot SFX per weapon category, fetched from Freesound/Pixabay.
- Commit each weapon and the gunsmith UI separately.

## PHASE 3 — AI Bots + Vehicles + World Sound

- AI bots via NavigationAgent3D: pathfinding, cover-seeking, target acquisition, shooting logic. Start 8v8 (config constant), win condition = eliminate all enemy bots.
- Kill/death/respawn logic, basic team behavior.
- Vehicles: Jeep, Truck, Military car — VehicleBody3D physics, enter/exit interaction, engine sound loops, collision damage.
- Footstep/impact/hit-marker/kill-confirm sounds per surface type (grass, concrete, metal) from Freesound/Pixabay.
- Commit bot pathfinding, bot combat, each vehicle, and sound integration separately.

## PHASE 4 — World Detail, Menu, Minimap, Polish

- Detail the mountain-ruins map: broken building shells, scattered furniture/debris props, roads, foliage — PBR textures/normal maps from Kenney/OpenGameArt/Quaternius for realism.
- Tab-hold 2D minimap: SubViewport top-down camera or pre-baked map texture with live player/teammate icons.
- Main menu: sci-fi/military theme, "The Battle of Claude" branding, Play / Gunsmith / Settings.
- Postprocess tuning: glow, SSAO, SSR, volumetric fog, color grading, dynamic shadows — balanced against frame rate.
- Performance pass: LOD, foliage multimesh instancing, bot-count scaling test toward 20v20, occlusion culling.
- Commit each step separately.

---

## GUNSMITH STAT DATA

### Base Weapon Stats (before attachments)

| Weapon | Damage (near/far) | Fire Rate (RPM) | Mag Size | Reload (s) | ADS Speed (s) | Recoil (v/h) | Range (dmg falloff starts) |
|---|---|---|---|---|---|---|---|
| AR | 30/18 | 650 | 30 | 2.3 | 0.25 | 2.2/1.0 | 40m |
| SMG | 22/10 | 850 | 25 | 1.8 | 0.18 | 1.6/1.4 | 20m |
| Shotgun (pellets) | 12x8/4x8 | 70 | 6 | 3.0 | 0.30 | 4.0/2.0 | 8m |
| LMG | 28/20 | 600 | 100 | 4.5 | 0.35 | 2.8/1.2 | 50m |
| Sniper | 95/70 | 45 (bolt) | 5 | 3.5 | 0.45 | 3.5/0.5 | 100m |
| Pistol | 25/14 | 400 (semi) | 12 | 1.5 | 0.15 | 1.8/0.8 | 15m |
| Knife | 55 (75 backstab) | melee | — | — | — | — | 1.5m |

### Attachment Modifiers (multiplicative unless noted)

| Slot | Attachment | Recoil V | Recoil H | ADS Speed | Damage/Range | Mag Size | Movement |
|---|---|---|---|---|---|---|---|
| Optic | Red Dot | -5% | 0% | +5% | 0% | — | 0% |
| Optic | Holographic | -8% | -3% | 0% | 0% | — | 0% |
| Optic | 4x Scope | -10% | -5% | -20% | +15% range | — | -3% |
| Optic | 8x Sniper Scope | -15% | -10% | -35% | +30% range | — | -5% |
| Barrel | Compensator | -15% | -20% | -5% | 0% | — | 0% |
| Barrel | Long Barrel | -5% | 0% | -10% | +20% range | — | -3% |
| Barrel | Suppressor | -10% | -5% | -8% | -10% dmg | — | -2% (no muzzle flash, reduced audio range) |
| Magazine | Extended Mag | 0% | 0% | -5% | 0% | +50% | -3% |
| Magazine | Fast Mag | 0% | 0% | 0% | 0% | 0% | 0% (reload speed -25% instead) |
| Grip | Vertical Grip | -20% | -10% | -8% | 0% | — | 0% |
| Grip | Angled Grip | -5% | -5% | +12% | 0% | — | 0% |
| Muzzle | Flash Hider | -5% | -5% | 0% | 0% | — | 0% (reduces enemy hit-flinch feedback) |

### Implementation Rules

- Stack attachments **multiplicatively** per stat, not additively (e.g. two -10% recoil attachments = ×0.9×0.9, not -20%).
- Only **one attachment per slot type** equipped at once (Optic / Barrel / Magazine / Grip / Muzzle = 5 slots max).
- Store all data as Godot `.tres` Resource files (e.g. `weapon_ar.tres`, `attachment_compensator.tres`) referenced by the gunsmith UI.

---

## FIRST STEP

Start with Phase 1 now. Scaffold the project, export a runnable build, and show the result before touching Phase 2.
