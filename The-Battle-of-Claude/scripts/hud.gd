extends CanvasLayer
## FPS HUD: crosshair, weapon name, ammo counter, health bar. Follows the active
## weapon via the loadout's weapon_switched signal.

@onready var ammo_label: Label = $Ammo
@onready var weapon_label: Label = $WeaponName
@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthBar/Value

var _weapon: Weapon


func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player != null:
		player.health_changed.connect(_on_health_changed)
		_on_health_changed(player.get_health(), player.max_health)

	var loadout := get_tree().get_first_node_in_group("loadout")
	if loadout != null:
		loadout.weapon_switched.connect(_bind_weapon)
		_bind_weapon(loadout.get_active_weapon())


func _bind_weapon(weapon: Weapon) -> void:
	if weapon == null:
		return
	if _weapon != null and is_instance_valid(_weapon):
		if _weapon.ammo_changed.is_connected(_on_ammo_changed):
			_weapon.ammo_changed.disconnect(_on_ammo_changed)
		if _weapon.reload_started.is_connected(_on_reload_started):
			_weapon.reload_started.disconnect(_on_reload_started)

	_weapon = weapon
	_weapon.ammo_changed.connect(_on_ammo_changed)
	_weapon.reload_started.connect(_on_reload_started)
	weapon_label.text = _weapon.data.weapon_name
	var ammo := _weapon.current_ammo()
	_on_ammo_changed(ammo.x, ammo.y)


func _on_ammo_changed(mag: int, reserve: int) -> void:
	if mag < 0:
		ammo_label.text = "—" # melee, no ammo
	else:
		ammo_label.text = "%d / %d" % [mag, reserve]


func _on_reload_started(_duration: float) -> void:
	ammo_label.text = "RELOADING"


func _on_health_changed(current: float, maximum: float) -> void:
	health_bar.max_value = maximum
	health_bar.value = current
	health_label.text = "%d" % roundi(current)
