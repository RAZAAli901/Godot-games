# Godot Games

A collection of games built with the [Godot Engine](https://godotengine.org/). Each game lives in its own top-level folder as a self-contained Godot project.

## Games

| Game | Folder | Engine | Type | Status |
|---|---|---|---|---|
| The Battle of Claude | [`The-Battle-of-Claude/`](The-Battle-of-Claude/) | Godot 4.7.1 | Battlefield-style FPS vs AI bots | Playable — all 4 phases in |

## Repository layout

```
Godot-games/
├── README.md                 <- you are here
└── The-Battle-of-Claude/     <- one folder per game (self-contained Godot project)
    ├── project.godot
    ├── BRIEF.md
    └── ...
```

To add a new game, create a new top-level folder containing its own `project.godot` and add a row to the table above.

## Getting started

Each game is a standalone Godot project — you run it by opening its folder.

**The Battle of Claude** (Godot 4.7.1):

1. Get the engine — [Godot 4.7.1 Standard/GDScript](https://godotengine.org/download/archive/4.7.1-stable/) (a single portable `.exe`).
2. Launch Godot → **Import** → pick `The-Battle-of-Claude/project.godot` → open.
3. Press **F5** to play. You boot into the main menu → **PLAY**.

Or launch straight from a terminal (PowerShell — the leading `&` is required to
run a quoted `.exe` path; use your own Godot + project paths):

```powershell
& "D:\godot\Godot_v4.7.1-stable_win64.exe" --path "D:\godot games\The-Battle-of-Claude"
```

Full setup, controls and how to build a standalone `.exe` are in the game's own
[README](The-Battle-of-Claude/README.md).

## Clone

```bash
git clone https://github.com/RAZAAli901/Godot-games.git
```
