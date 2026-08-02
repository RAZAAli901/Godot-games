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
- ⬜ Phase 2 — full weapon roster + gunsmith (next)

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
