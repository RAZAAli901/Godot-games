extends CanvasLayer
## In-game gunsmith. Press G to open (pauses the game and frees the mouse).
## Swap the primary weapon and fit one attachment per slot; every change is
## applied to the real weapon immediately and reflected in the live stat panel.

const SLOTS: Array[String] = ["Optic", "Barrel", "Magazine", "Grip", "Muzzle"]
const CATALOG: Array[AttachmentData] = [
	preload("res://resources/attachments/optic_red_dot.tres"),
	preload("res://resources/attachments/optic_holographic.tres"),
	preload("res://resources/attachments/optic_4x_scope.tres"),
	preload("res://resources/attachments/optic_8x_scope.tres"),
	preload("res://resources/attachments/barrel_compensator.tres"),
	preload("res://resources/attachments/barrel_long.tres"),
	preload("res://resources/attachments/barrel_suppressor.tres"),
	preload("res://resources/attachments/mag_extended.tres"),
	preload("res://resources/attachments/mag_fast.tres"),
	preload("res://resources/attachments/grip_vertical.tres"),
	preload("res://resources/attachments/grip_angled.tres"),
	preload("res://resources/attachments/muzzle_flash_hider.tres"),
]

@onready var primary_option: OptionButton = $Panel/Margin/VBox/PrimaryRow/PrimaryOption
@onready var slots_box: VBoxContainer = $Panel/Margin/VBox/Slots
@onready var stats_label: RichTextLabel = $Panel/Margin/VBox/Stats

var _loadout: Loadout
var _by_slot: Dictionary = {}      # slot -> Array[AttachmentData]
var _slot_options: Dictionary = {} # slot -> OptionButton


func _ready() -> void:
	layer = 20
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_loadout = get_tree().get_first_node_in_group("loadout")
	_bucket_catalog()
	_populate_primary()
	_build_slot_rows()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("gunsmith"):
		toggle()
		get_viewport().set_input_as_handled()


func toggle() -> void:
	visible = not visible
	get_tree().paused = visible
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if visible else Input.MOUSE_MODE_CAPTURED
	if visible:
		_sync_from_loadout()


# ---------------------------------------------------------------- build

func _bucket_catalog() -> void:
	for slot in SLOTS:
		_by_slot[slot] = []
	for a in CATALOG:
		if _by_slot.has(a.slot):
			_by_slot[a.slot].append(a)


func _populate_primary() -> void:
	if _loadout == null:
		return
	for wd in _loadout.available_primaries():
		primary_option.add_item(wd.weapon_name)
	primary_option.item_selected.connect(_on_primary_selected)


func _build_slot_rows() -> void:
	for slot in SLOTS:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)

		var label := Label.new()
		label.text = slot
		label.custom_minimum_size = Vector2(110, 0)
		row.add_child(label)

		var opt := OptionButton.new()
		opt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		opt.add_item("None")
		for a in _by_slot[slot]:
			opt.add_item(a.attachment_name)
		opt.item_selected.connect(_on_slot_selected.bind(slot))
		row.add_child(opt)

		_slot_options[slot] = opt
		slots_box.add_child(row)


# ---------------------------------------------------------------- edits

func _on_primary_selected(index: int) -> void:
	_loadout.set_primary_index(index)
	_sync_slots_from_weapon()
	_refresh_stats()


func _on_slot_selected(index: int, slot: String) -> void:
	var attachment: AttachmentData = null
	if index > 0:
		attachment = _by_slot[slot][index - 1]
	var primary := _loadout.get_primary()
	if primary != null:
		primary.set_attachment(slot, attachment)
	_refresh_stats()


# ---------------------------------------------------------------- sync / view

func _sync_from_loadout() -> void:
	if _loadout == null:
		return
	primary_option.select(_loadout.get_primary_index())
	_sync_slots_from_weapon()
	_refresh_stats()


func _sync_slots_from_weapon() -> void:
	var primary := _loadout.get_primary()
	if primary == null:
		return
	for slot in SLOTS:
		var opt: OptionButton = _slot_options[slot]
		var equipped: AttachmentData = primary.get_attachment(slot)
		var idx := 0
		if equipped != null:
			idx = _by_slot[slot].find(equipped) + 1
		opt.select(idx)


func _refresh_stats() -> void:
	var primary := _loadout.get_primary()
	if primary == null:
		return
	var s := primary.effective_stats()
	stats_label.text = "\n".join([
		"[b]%s[/b]  (%s)" % [s["name"], s["category"]],
		"Damage: %.0f / %.0f%s" % [s["damage_near"], s["damage_far"], (" x%d" % s["pellets"]) if s["pellets"] > 1 else ""],
		"Fire rate: %.0f RPM" % s["rpm"],
		"Mag: %d" % s["mag"],
		"Reload: %.2f s" % s["reload"],
		"ADS: %.2f s" % s["ads"],
		"Recoil (v/h): %.3f / %.3f" % [s["recoil_v"], s["recoil_h"]],
		"Range: %.0f–%.0f m" % [s["range_start"], s["range_end"]],
		"Move: %d%%" % roundi(s["move"] * 100.0),
	])
