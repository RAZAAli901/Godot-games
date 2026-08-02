# The Battle of Claude

Battlefield-style first-person shooter vs AI bots. Godot 4.7.1 (GDScript, Jolt
physics). Built in phases — see [BRIEF.md](BRIEF.md) for the full design.

## Status

**Phase 1 — Core FPS Foundation: complete.**

- ✅ Godot project, Jolt physics, WorldEnvironment (SSAO / SSR / glow / fog / ACES)
- ✅ First-person controller: move, mouse-look, sprint, crouch, jump, head-bob
- ✅ Greybox arena (~1.5 km ground) with cover, ramps, ruin-hills, targets
- ✅ Test AR: hitscan, range damage falloff, climbing recoil, muzzle flash
- ✅ HUD: crosshair, ammo counter, health bar

**Phase 2 — Full Weapon System + Gunsmith: in progress.**

- ✅ 7-weapon roster (AR / SMG / Shotgun / LMG / Sniper / Pistol / Knife), all
  stats as `.tres`; pellets, semi/bolt/auto, melee, ADS zoom, move penalty
- ✅ Loadout (Primary + Pistol + Knife) with 1/2/3 switching
- ✅ Gunsmith (press `G`): swap primary + one attachment per slot; 12 attachments
  fold multiplicatively onto real stats with a live preview
- ✅ Per-weapon gunshot SFX (procedural placeholder); suppressor quietens
- ✅ Real weapon models (Kenney Blaster Kit, CC0) for the 6 guns
- ⬜ Reload animations (needs an FPS-arm rig — see ASSETS_CREDITS.md)
- ⬜ Knife blade model + real recorded SFX (manual asset sourcing)

**Phase 3 — AI Bots + Vehicles + World Sound: in progress.**

- ✅ Navmesh baked over the arena; bots pathfind + route around cover
- ✅ AI bots: target acquisition, line-of-sight, hitscan combat, death
- ✅ 8v8 team deathmatch (config `team_size`), live score, win/lose banner,
  player respawn
- ✅ Drivable jeep (VehicleBody3D): enter/exit, engine sound, ram damage
- ✅ World SFX: footsteps, bullet impacts, hit-marker + kill-confirm
- ⬜ Truck + military-car variants, bot cover-seeking polish (follow-up)

## Controls

| Action | Key |
|---|---|
| Move | `W` `A` `S` `D` |
| Look | Mouse |
| Sprint | `Shift` (hold, forward) |
| Crouch | `Ctrl` (hold) |
| Jump | `Space` |
| Fire | Left Mouse |
| Aim (ADS) | Right Mouse |
| Reload | `R` |
| Switch weapon | `1` Primary / `2` Pistol / `3` Knife |
| Gunsmith | `G` |
| Enter / exit vehicle | `E` (near it) |
| Release mouse | `Esc` |

## Run

Open the folder in Godot 4.7.1, or from a terminal:

```bash
godot --path .
```

## Layout

```
The-Battle-of-Claude/
├── project.godot            Engine config, input map, tunable game values
├── scenes/
│   ├── main.tscn            Root: environment, sun, world, player, HUD
│   ├── player/player.tscn   CharacterBody3D FPS rig (camera, weapon mount)
│   ├── weapons/ar.tscn      Greybox AR + muzzle flash
│   ├── world/               terrain.tscn, target_dummy.tscn
│   └── ui/hud.tscn          Crosshair, ammo, health
├── scripts/                 GDScript for each system
└── resources/
    ├── default_env.tres     WorldEnvironment
    └── weapons/weapon_ar.tres  AR stats (tunable, no code changes)
```

Weapon balance lives in `.tres` resources so it can be tuned without touching
code. Bot count, map size and mouse sensitivity are project-setting values under
`[game]` in `project.godot`.
