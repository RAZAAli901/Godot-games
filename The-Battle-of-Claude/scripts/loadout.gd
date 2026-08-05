extends Node3D
class_name Loadout
## Owns the player's weapons. The loadout is fixed to exactly three real guns
## — no generic primary/secondary/melee split, no pistol, no knife — switched
## with 1/2/3. Gunsmith attachments apply to whichever gun is currently out.

const WeaponScene: PackedScene = preload("res://scenes/weapons/weapon.tscn")

## The only three weapons that exist in the game.
const WEAPONS: Array[WeaponData] = [
	preload("res://resources/weapons/weapon_carbine.tres"),
	preload("res://resources/weapons/weapon_bullpup.tres"),
	preload("res://resources/weapons/weapon_sniper_real.tres"),
]

signal weapon_switched(weapon: Weapon)

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
	for data in WEAPONS:
		_spawn(data)
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

func set_combat_enabled(on: bool) -> void:
	var w := get_active_weapon()
	if w != null:
		w.set_active(on)


func get_active_weapon() -> Weapon:
	return _weapons[_active] if _active < _weapons.size() else null


## Kept as "primary" for gunsmith.gd's existing dropdown/API shape — with only
## three guns total there's no separate primary/secondary tier anymore, this
## just means "whichever of the three is currently equipped".
func get_primary() -> Weapon:
	return get_active_weapon()


func get_primary_index() -> int:
	return _active


func available_primaries() -> Array[WeaponData]:
	return WEAPONS


## Switches weapons. Unlike the old version this no longer rebuilds the whole
## loadout, so attachments fitted to the other two guns are preserved when you
## swap back to them.
func set_primary_index(index: int) -> void:
	switch_to(index)
