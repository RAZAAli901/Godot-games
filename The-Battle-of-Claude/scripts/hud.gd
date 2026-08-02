extends CanvasLayer
## FPS HUD: crosshair, weapon name, ammo counter, health bar. Follows the active
## weapon via the loadout's weapon_switched signal.

@onready var ammo_label: Label = $Ammo
@onready var weapon_label: Label = $WeaponName
@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthBar/Value
@onready var score_label: Label = $Score
@onready var banner: Label = $Banner

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

	var match_mgr := get_tree().get_first_node_in_group("match")
	if match_mgr != null:
		match_mgr.counts_changed.connect(_on_counts_changed)
		match_mgr.match_ended.connect(_on_match_ended)


func _on_counts_changed(allies: int, enemies: int) -> void:
	score_label.text = "Allies %d      Enemies %d" % [allies, enemies]


func _on_match_ended(player_won: bool) -> void:
	banner.text = "VICTORY" if player_won else "DEFEAT"
	banner.modulate = Color(0.5, 0.9, 0.5) if player_won else Color(0.95, 0.4, 0.35)
	banner.visible = true


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
