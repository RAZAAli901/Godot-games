extends Node3D
class_name Loadout
## Owns the player's three weapon slots (Primary + Pistol + Knife), spawns a
## weapon instance per slot, and switches between them (keys 1/2/3). The primary
## can be swapped from the available list and its attachments edited by the
## gunsmith. Also drives the equipped weapon's movement penalty on the player.

const WeaponScene: PackedScene = preload("res://scenes/weapons/weapon.tscn")

const PRIMARIES: Array[WeaponData] = [
	preload("res://resources/weapons/weapon_ar.tres"),
	preload("res://resources/weapons/weapon_smg.tres"),
	preload("res://resources/weapons/weapon_shotgun.tres"),
	preload("res://resources/weapons/weapon_lmg.tres"),
	preload("res://resources/weapons/weapon_sniper.tres"),
]
const SECONDARY: WeaponData = preload("res://resources/weapons/weapon_pistol.tres")
const MELEE: WeaponData = preload("res://resources/weapons/weapon_knife.tres")

signal weapon_switched(weapon: Weapon)

var _primary_index: int = 0
var _weapons: Array[Weapon] = []
var _active: int = 0
var _player: CharacterBody3D


func _ready() -> void:
	add_to_group("loadout")
	_player = get_tree().get_first_node_in_group("player")
	_build()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("weapon_1"):
		switch_to(0)
	elif Input.is_action_just_pressed("weapon_2"):
		switch_to(1)
	elif Input.is_action_just_pressed("weapon_3"):
		switch_to(2)


func _build() -> void:
	for w in _weapons:
		if is_instance_valid(w):
			w.queue_free()
	_weapons.clear()
	_spawn(PRIMARIES[_primary_index])
	_spawn(SECONDARY)
	_spawn(MELEE)
	_active = 0
	_apply_active()


func _spawn(data: WeaponData) -> void:
	var w: Weapon = WeaponScene.instantiate()
	w.data = data
	add_child(w)
	_weapons.append(w)


func switch_to(index: int) -> void:
	if index < 0 or index >= _weapons.size() or index == _active:
		return
	_active = index
	_apply_active()


func _apply_active() -> void:
	for i in _weapons.size():
		_weapons[i].set_active(i == _active)
	var w := _weapons[_active]
	if _player != null and _player.has_method("set_weapon_move_mult"):
		_player.set_weapon_move_mult(w.effective_move_mult())
	weapon_switched.emit(w)


# ---------------------------------------------------------------- gunsmith API

func get_active_weapon() -> Weapon:
	return _weapons[_active] if _active < _weapons.size() else null


func get_primary() -> Weapon:
	return _weapons[0] if _weapons.size() > 0 else null


func get_primary_index() -> int:
	return _primary_index


func available_primaries() -> Array[WeaponData]:
	return PRIMARIES


func set_primary_index(index: int) -> void:
	_primary_index = clampi(index, 0, PRIMARIES.size() - 1)
	_build()
