# Battle of Claude — integration guide

This zip only contains the new/changed **project files** (all tiny text files).
It does **not** contain your 4 GLBs — you already have those locally, no need
to double them up into a 100MB+ download. You'll copy them in yourself.

## Important discovery

`chicken_gun_fruzer_western.glb` is **not a gun** — it's a 93MB scene dump of
the entire Synty "PolygonWesternFrontier" asset pack (1,556 meshes: forts,
walls, corner towers, stairs, mine tunnels, rivers, wagons, the works). That's
your **map**. The 3 real guns are `fps_animated_carbine (1).glb`,
`bullpuppy.glb`, and `sniper_animated.glb`.

## Step 1 — copy your 4 GLBs into the project

Create these folders under `The-Battle-of-Claude/` and drop your files in,
**renamed exactly as below** (the .tres/.tscn files in this patch reference
these exact paths):

```
The-Battle-of-Claude/
  assets/
    weapons/
      fps_carbine.glb     ← fps_animated_carbine (1).glb
      bullpup.glb         ← bullpuppy.glb
      sniper.glb          ← sniper_animated.glb
    map/
      western_frontier.glb ← chicken_gun_fruzer_western.glb
```

## Step 2 — overwrite these existing files with the ones in this zip

```
project.godot                ← adds the ` (backtick) "calibrate" input action
scenes/main.tscn             ← swaps the world to the new map, adds the calibrator UI
scripts/loadout.gd           ← loadout is now exactly these 3 guns (no pistol/knife)
scripts/weapon.gd            ← adds get_view_model() / data_resource_path() for the calibrator
```

## Step 3 — add these new files

```
resources/weapons/weapon_carbine.tres
resources/weapons/weapon_bullpup.tres
resources/weapons/weapon_sniper_real.tres
scripts/weapon_calibrator.gd
scenes/ui/weapon_calibrator.tscn
scripts/map_collision_gen.gd
scenes/world/western_frontier_map.tscn
```

Preserve the folder structure shown in this zip — everything already sits at
the right relative path, so you can literally drag the zip's contents on top
of `The-Battle-of-Claude/` and let it merge.

## Step 4 — open in Godot 4.7.1

First open will take a while: Godot has to import the 93MB/1500-mesh map GLB
plus the 3 gun GLBs. Let it finish before pressing Play.

## What you get

- **Weapons**: only the 3 guns exist now. `1`/`2`/`3` switch Carbine / Bullpup
  / Sniper. Existing ADS (right-click), fire, reload, recoil, hitscan damage
  falloff, and the FPS controller (WASD, sprint, crouch, jump, mouse-look) are
  all untouched — that logic was already solid, I didn't need to rebuild it.
- **Gunsmith** (`G`) still works and now edits attachments on whichever of the
  3 guns is currently equipped.
- **Manual gun calibration** (press `` ` ``, the backtick key): a panel with
  Pos X / Pos Y / Pos Z / Rot Y / Scale sliders — same idea as your
  screenshot — that live-drags the *currently equipped* gun's real mesh.
  Every change is applied immediately and printed to the Godot Output console
  like:
  ```
  [WeaponCalibrator] FPS Carbine (res://resources/weapons/weapon_carbine.tres)
    model_offset = Vector3(0.120, -0.080, -0.300)
    model_euler_deg = Vector3(0, -4.0, 0)
    model_scale = 0.850
  ```
  Copy those 3 lines' values into the matching `.tres` (`model_offset`,
  `model_euler_deg`, `model_scale`) to make your calibration permanent instead
  of resetting next time you launch. Switching weapons (1/2/3) while the panel
  is open re-targets it to the new gun automatically.

## Known caveats (things I couldn't verify without running the Godot editor)

- **Player spawn / map scale**: I couldn't compute the real bounding box or
  ground height of the western frontier scene from outside the editor (glTF
  stores its transforms as matrices, not plain position/scale, so a text-only
  read can't resolve world-space bounds reliably). The `Player` node in
  `main.tscn` still spawns at `(0, 2, 0)` — open the scene, see where that
  lands relative to the imported map, and drag the `Player` (and/or the
  `World` node's transform, if the whole map needs to be moved/scaled) to a
  sensible spot on the ground. I didn't want to guess numbers and have you
  spawn underground or a kilometre from anything.
- **Collision**: `map_collision_gen.gd` auto-bakes a trimesh `StaticBody3D`
  for all ~1,500 meshes at runtime on load — correct, but causes a load-time
  hitch. For a permanent, faster-loading fix: in the editor, select the
  imported map's root → **Mesh → Create Trimesh Static Body** once, save the
  scene, then delete `map_collision_gen.gd` from the node.
- **Bullpup has no hands/animation** — it's a static mesh with no skeleton in
  the source file, unlike the carbine and sniper (which include an animated
  arm rig and an `allanims` animation the game's existing fire/reload
  animation lookup will use automatically if matching clip names exist inside
  it). The bullpup will render as a floating gun with no arms unless you swap
  in a rigged model later.
- **Scale/offset starting values**: I derived `model_scale = 1.0` for all
  three guns from the glTF unit matrices baked into the FBX→glb export (their
  raw mesh extents work out to a very plausible ~0.9–1.6 m gun length once
  that matrix is applied), so these should land close, but the backtick panel
  is there specifically so you can nail the final feel per-gun without needing
  me to guess further.
