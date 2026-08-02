extends Control
## Settings panel. Applies changes live to project config / audio / display so
## both the menu and the in-game pause menu can reuse it.

signal closed

@onready var sens_slider: HSlider = $Panel/Margin/VBox/Sensitivity/Slider
@onready var sens_value: Label = $Panel/Margin/VBox/Sensitivity/Value
@onready var team_slider: HSlider = $Panel/Margin/VBox/TeamSize/Slider
@onready var team_value: Label = $Panel/Margin/VBox/TeamSize/Value
@onready var volume_slider: HSlider = $Panel/Margin/VBox/Volume/Slider
@onready var fullscreen_check: CheckButton = $Panel/Margin/VBox/Fullscreen/Check
@onready var back_button: Button = $Panel/Margin/VBox/Back


func _ready() -> void:
	sens_slider.value = ProjectSettings.get_setting("game/config/mouse_sensitivity", 0.0025)
	team_slider.value = ProjectSettings.get_setting("game/config/team_size", 8)
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	fullscreen_check.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	_update_labels()

	sens_slider.value_changed.connect(_on_sens_changed)
	team_slider.value_changed.connect(_on_team_changed)
	volume_slider.value_changed.connect(_on_volume_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	back_button.pressed.connect(func(): closed.emit())


func _update_labels() -> void:
	sens_value.text = "%d%%" % roundi(sens_slider.value / 0.0025 * 100.0)
	team_value.text = "%dv%d" % [int(team_slider.value), int(team_slider.value)]


func _on_sens_changed(v: float) -> void:
	ProjectSettings.set_setting("game/config/mouse_sensitivity", v)
	_update_labels()


func _on_team_changed(v: float) -> void:
	ProjectSettings.set_setting("game/config/team_size", int(v))
	_update_labels()


func _on_volume_changed(v: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(0.0001, v)))


func _on_fullscreen_toggled(on: bool) -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if on else DisplayServer.WINDOW_MODE_WINDOWED)
