# Asset Credits

Every third-party asset used in *The Battle of Claude* is logged here with its
source URL and license, per the ASSET SOURCING RULES in [BRIEF.md](BRIEF.md).

## In use

| Asset | Type | Source | License | Used in |
|---|---|---|---|---|
| Kenney Blaster Kit 2.1 | 3D models (GLB) | https://kenney.nl/assets/blaster-kit | CC0 1.0 | Weapon view models (AR/SMG/Shotgun/LMG/Sniper/Pistol) — `assets/models/blaster-kit/` |

Gunshot SFX are currently **procedurally generated** in code (`scripts/sfx.gd`)
as a no-dependency placeholder. `WeaponData.fire_sound` is the override slot for
dropping in real clips.

## Still to source

Per the brief, these need manual download (Sketchfab/Mixamo require a login, so
they are flagged here rather than auto-fetched — place files in
`assets/incoming/` for import):

- **Combat Knife model** — Blaster Kit has no blade; the knife still uses a
  greybox mesh. Search Kenney / Quaternius / OpenGameArt for a CC0 "knife" or
  "combat knife" low-poly model.
- **FPS arm rig + reload animations** — search Mixamo for "rifle reload",
  "pistol reload", "reload" arm animations (FBX), or a Sketchfab CC "FPS arms"
  rig, to drive an AnimationTree reload state machine (BRIEF Phase 2).
- **Real gunshot SFX per category** — search Freesound / Pixabay for CC0
  "assault rifle shot", "smg", "shotgun blast", "sniper rifle", "pistol",
  "lmg" one-shots (.ogg/.wav) to replace the procedural placeholders.
