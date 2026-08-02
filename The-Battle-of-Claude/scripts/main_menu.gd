extends Control
## Sci-fi main menu. Play launches the match; Gunsmith launches straight into the
## gunsmith; Settings opens the shared settings panel; Quit exits.

@onready var settings: Control = $Settings


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	settings.visible = false
	settings.closed.connect(func(): settings.visible = false)
	$Center/Buttons/Play.pressed.connect(_on_play)
	$Center/Buttons/Gunsmith.pressed.connect(_on_gunsmith)
	$Center/Buttons/Settings.pressed.connect(func(): settings.visible = true)
	$Center/Buttons/Quit.pressed.connect(func(): get_tree().quit())


func _on_play() -> void:
	GameState.open_gunsmith = false
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_gunsmith() -> void:
	GameState.open_gunsmith = true
	get_tree().change_scene_to_file("res://scenes/main.tscn")
