# Asset Credits

Every third-party asset used in *The Battle of Claude* is logged here with its
source URL and license, per the ASSET SOURCING RULES in [BRIEF.md](BRIEF.md).

## In use

| Asset | Type | Source | License | Used in |
|---|---|---|---|---|
| Kenney Blaster Kit 2.1 | 3D models (GLB) | https://kenney.nl/assets/blaster-kit | CC0 1.0 | Weapon view models — `assets/models/blaster-kit/` |
| Quaternius Animated Guns Pack | 3D models + animations (FBX) | https://quaternius.com/packs/animatedguns.html | CC0 1.0 | Animated weapons (P90, Pistol, Revolver, Rifle, Shotgun, Sniper) — `assets/models/guns/animated/` |
| Quaternius Ultimate Guns Pack | 3D models (OBJ) | https://quaternius.com/packs/ultimategun.html | CC0 1.0 | Static gun geometry placeholders (untextured) — `assets/models/guns/static/` |
| Quaternius Ultimate Stylized Nature Pack | 3D models + textures (glTF) | https://quaternius.com/packs/ultimatestylizednature.html | CC0 1.0 | Stylized trees, bushes, flowers & rocks — `assets/models/nature/` |

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
