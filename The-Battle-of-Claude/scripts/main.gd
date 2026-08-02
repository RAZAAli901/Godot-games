extends Node3D
## Root scene controller for The Battle of Claude.
## Owns global concerns: mouse capture and the pause / release toggle.

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	# Release / recapture the mouse so the window can be closed or debugged.
	if event.is_action_pressed("ui_toggle_mouse"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
