extends Node3D
## Root scene controller for the match. Owns mouse capture, the Esc pause menu,
## and honours the menu's "open gunsmith on start" request.

@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var gunsmith: CanvasLayer = $Gunsmith


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if GameState.open_gunsmith:
		GameState.open_gunsmith = false
		await get_tree().process_frame
		gunsmith.toggle()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_toggle_mouse"):
		# Esc closes the gunsmith if open, otherwise toggles the pause menu.
		if gunsmith.visible:
			gunsmith.toggle()
		else:
			pause_menu.toggle()
