extends CanvasLayer
## Manual view-model calibration overlay. Press ` (backtick) to toggle.
## Drags the CURRENTLY EQUIPPED weapon's real mesh around with five sliders —
## Pos X / Pos Y / Pos Z / Rot Y / Scale — exactly like the reference
## "WEAPON CALIBRATION" panel. Every change is applied live to the weapon so
## you can see it in first person immediately, and the resulting numbers are
## printed to the Output console so you can copy them straight into the
## matching resources/weapons/*.tres (model_offset / model_euler_deg.y /
## model_scale) to make them the new permanent defaults.

@onready var panel: Panel = $Panel
@onready var weapon_label: Label = $Panel/Margin/VBox/WeaponLabel
@onready var pos_x: HSlider = $Panel/Margin/VBox/PosXRow/Slider
@onready var pos_y: HSlider = $Panel/Margin/VBox/PosYRow/Slider
@onready var pos_z: HSlider = $Panel/Margin/VBox/PosZRow/Slider
@onready var rot_y: HSlider = $Panel/Margin/VBox/RotYRow/Slider
@onready var scale_s: HSlider = $Panel/Margin/VBox/ScaleRow/Slider
@onready var pos_x_val: Label = $Panel/Margin/VBox/PosXRow/Value
@onready var pos_y_val: Label = $Panel/Margin/VBox/PosYRow/Value
@onready var pos_z_val: Label = $Panel/Margin/VBox/PosZRow/Value
@onready var rot_y_val: Label = $Panel/Margin/VBox/RotYRow/Value
@onready var scale_val: Label = $Panel/Margin/VBox/ScaleRow/Value

var _loadout: Loadout
var _syncing: bool = false


func _ready() -> void:
	layer = 25
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_loadout = get_tree().get_first_node_in_group("loadout")
	if _loadout != null:
		_loadout.weapon_switched.connect(_on_weapon_switched)

	pos_x.value_changed.connect(_on_slider_changed)
	pos_y.value_changed.connect(_on_slider_changed)
	pos_z.value_changed.connect(_on_slider_changed)
	rot_y.value_changed.connect(_on_slider_changed)
	scale_s.value_changed.connect(_on_slider_changed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("calibrate"):
		toggle()
		get_viewport().set_input_as_handled()


func toggle() -> void:
	visible = not visible
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if visible else Input.MOUSE_MODE_CAPTURED
	if visible:
		_sync_from_weapon()


func _on_weapon_switched(_w: Weapon) -> void:
	if visible:
		_sync_from_weapon()


func _current_view_model() -> Node3D:
	if _loadout == null:
		return null
	var w := _loadout.get_active_weapon()
	if w == null:
		return null
	return w.get_view_model()


func _sync_from_weapon() -> void:
	var vm := _current_view_model()
	if vm == null:
		return
	_syncing = true
	pos_x.value = vm.position.x
	pos_y.value = vm.position.y
	pos_z.value = vm.position.z
	rot_y.value = vm.rotation_degrees.y
	scale_s.value = vm.scale.x
	_syncing = false
	var w := _loadout.get_active_weapon()
	weapon_label.text = "WEAPON CALIBRATION — %s" % w.data.weapon_name
	_refresh_labels()


func _on_slider_changed(_v: float) -> void:
	if _syncing:
		return
	var vm := _current_view_model()
	if vm == null:
		return
	vm.position = Vector3(pos_x.value, pos_y.value, pos_z.value)
	vm.rotation_degrees.y = rot_y.value
	vm.scale = Vector3.ONE * scale_s.value
	_refresh_labels()
	_log_config()


func _refresh_labels() -> void:
	pos_x_val.text = "%.2f" % pos_x.value
	pos_y_val.text = "%.2f" % pos_y.value
	pos_z_val.text = "%.2f" % pos_z.value
	rot_y_val.text = "%.0f°" % rot_y.value
	scale_val.text = "%.2f" % scale_s.value


func _log_config() -> void:
	var w := _loadout.get_active_weapon()
	if w == null:
		return
	print("[WeaponCalibrator] %s (%s)" % [w.data.weapon_name, w.data_resource_path()])
	print("  model_offset = Vector3(%.3f, %.3f, %.3f)" % [pos_x.value, pos_y.value, pos_z.value])
	print("  model_euler_deg = Vector3(0, %.1f, 0)" % rot_y.value)
	print("  model_scale = %.3f" % scale_s.value)
