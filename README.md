# Godot Games

A collection of games built with the [Godot Engine](https://godotengine.org/). Each game lives in its own top-level folder as a self-contained Godot project.

## Games

| Game | Folder | Engine | Type | Status |
|---|---|---|---|---|
| The Battle of Claude | [`The-Battle-of-Claude/`](The-Battle-of-Claude/) | Godot 4.7.1 | Battlefield-style FPS vs AI bots | Phase 1 — in progress |

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

## Building / running a game

Open the game's folder in the Godot editor, or run headlessly:

```bash
godot --path The-Battle-of-Claude
```
