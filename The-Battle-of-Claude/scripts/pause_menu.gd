extends CanvasLayer
## In-game pause menu (Esc). Pauses the tree, frees the mouse, and offers
## Resume / Settings / Main Menu / Quit. Reuses the shared settings panel.

@onready var settings: Control = $Settings


func _ready() -> void:
	layer = 30
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	settings.visible = false
	settings.closed.connect(func(): settings.visible = false)
	$Panel/VBox/Resume.pressed.connect(close)
	$Panel/VBox/Settings.pressed.connect(func(): settings.visible = true)
	$Panel/VBox/Menu.pressed.connect(_to_menu)
	$Panel/VBox/Quit.pressed.connect(func(): get_tree().quit())


func is_open() -> bool:
	return visible


func toggle() -> void:
	if visible:
		close()
	else:
		open()


func open() -> void:
	visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func close() -> void:
	visible = false
	settings.visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _to_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
