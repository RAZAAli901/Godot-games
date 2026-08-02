extends Node3D
class_name Weapon
## Data-driven weapon. All balance comes from a WeaponData resource with
## AttachmentData modifiers folded on top multiplicatively (one per slot).
## Handles auto/semi/bolt fire, shotgun pellets, melee, ADS zoom, recoil,
## muzzle flash and ammo/reload. Only the active weapon in a loadout processes.

@export var data: WeaponData

signal ammo_changed(mag: int, reserve: int)
signal fired()
signal reload_started(duration: float)

const DEFAULT_FOV := 75.0
const MELEE_MAG := -1 # sentinel: melee weapon, no ammo

var attachments: Dictionary = {} # slot(String) -> AttachmentData

# Effective (post-attachment) stats.
var _eff_recoil_v: float
var _eff_recoil_h: float
var _eff_reload: float
var _eff_mag: int
var _eff_ads: float
var _eff_damage_mult: float
var _eff_range_mult: float
var _eff_move_mult: float
var _no_flash: bool = false

var _mag: int = 0
var _reserve: int = 0
var _cooldown: float = 0.0
var _reloading: bool = false
var _reload_timer: float = 0.0
var _shot_index: int = 0
var _aiming: bool = false
var _active: bool = true
var _default_fov: float = DEFAULT_FOV

@onready var muzzle: Marker3D = $Muzzle
@onready var flash: GPUParticles3D = $Muzzle/Flash
@onready var flash_light: OmniLight3D = $Muzzle/FlashLight

var _camera: Camera3D
var _player: CharacterBody3D
var _view_model: Node3D


func _ready() -> void:
	add_to_group("weapon")
	_player = get_tree().get_first_node_in_group("player")
	if data == null:
		push_warning("Weapon has no WeaponData assigned.")
		return
	_build_view_model()
	_recompute()
	_reset_ammo()


# ---------------------------------------------------------------- view model

func _build_view_model() -> void:
	muzzle.position = Vector3(0, 0, -data.model_size.z * 0.5 - 0.02)
	if data.view_model != null:
		_view_model = data.view_model.instantiate()
		add_child(_view_model)
		return
	# Greybox: a single box sized/coloured from the data.
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = data.model_size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = data.model_color
	mat.metallic = 0.5
	mat.roughness = 0.5
	mesh.mesh = box
	mesh.material_override = mat
	add_child(mesh)
	_view_model = mesh


# ---------------------------------------------------------------- attachments

func set_attachment(slot: String, attachment: AttachmentData) -> void:
	if attachment == null:
		attachments.erase(slot)
	else:
		attachments[slot] = attachment
	_recompute()
	_reset_ammo()


func clear_attachments() -> void:
	attachments.clear()
	_recompute()
	_reset_ammo()


func _recompute() -> void:
	_eff_recoil_v = data.recoil_vertical
	_eff_recoil_h = data.recoil_horizontal
	_eff_reload = data.reload_time
	_eff_ads = data.ads_speed
	_eff_damage_mult = 1.0
	_eff_range_mult = 1.0
	_eff_move_mult = data.move_speed_mult
	_no_flash = false
	var magf := float(data.mag_size)
	for slot in attachments:
		var a: AttachmentData = attachments[slot]
		_eff_recoil_v *= a.recoil_v_mult
		_eff_recoil_h *= a.recoil_h_mult
		_eff_reload *= a.reload_mult
		_eff_ads *= a.ads_time_mult
		_eff_damage_mult *= a.damage_mult
		_eff_range_mult *= a.range_mult
		_eff_move_mult *= a.move_mult
		magf *= a.mag_mult
		if a.no_muzzle_flash:
			_no_flash = true
	_eff_mag = maxi(1, roundi(magf))


func _reset_ammo() -> void:
	if data.is_melee:
		ammo_changed.emit(MELEE_MAG, MELEE_MAG)
		return
	_reloading = false
	_mag = _eff_mag
	_reserve = _eff_mag * 6
	ammo_changed.emit(_mag, _reserve)


# ---------------------------------------------------------------- active state

func set_active(on: bool) -> void:
	_active = on
	visible = on
	set_process(on)
	if not on:
		_aiming = false
		_reloading = false


func is_aiming() -> bool:
	return _active and _aiming


func effective_move_mult() -> float:
	return _eff_move_mult


func current_ammo() -> Vector2i:
	return Vector2i(_mag, _reserve)


func is_reloading() -> bool:
	return _reloading


# ---------------------------------------------------------------- per-frame

func _process(delta: float) -> void:
	if data == null:
		return
	_cooldown = maxf(0.0, _cooldown - delta)
	if flash_light.light_energy > 0.0:
		flash_light.light_energy = maxf(0.0, flash_light.light_energy - delta * 60.0)

	_aiming = Input.is_action_pressed("aim")
	_update_ads(delta)

	if data.is_melee:
		if Input.is_action_just_pressed("fire") and _cooldown <= 0.0:
			_melee()
		return

	if _reloading:
		_reload_timer -= delta
		if _reload_timer <= 0.0:
			_finish_reload()
		return

	if Input.is_action_just_pressed("reload"):
		_start_reload()
		return

	var wants_fire := Input.is_action_pressed("fire") if data.automatic else Input.is_action_just_pressed("fire")
	if wants_fire and _can_fire():
		_fire()


func _update_ads(delta: float) -> void:
	var cam := _camera_ref()
	if cam == null:
		return
	var target := data.ads_fov if _aiming else _default_fov
	var rate := 1.0 / maxf(0.03, _eff_ads)
	cam.fov = lerpf(cam.fov, target, 1.0 - exp(-rate * delta))


# ---------------------------------------------------------------- firing

func _can_fire() -> bool:
	return not _reloading and _cooldown <= 0.0 and _mag > 0


func _fire() -> void:
	_mag -= 1
	_shot_index += 1
	_cooldown = 60.0 / data.fire_rate_rpm
	var spread := data.hip_spread_deg * (0.2 if _aiming else 1.0)
	for i in maxi(1, data.pellets):
		_hitscan(spread)
	if not _no_flash:
		_show_muzzle_flash()
	_kick()
	ammo_changed.emit(_mag, _reserve)
	fired.emit()
	if _mag == 0:
		_start_reload()


func _melee() -> void:
	_cooldown = 60.0 / data.fire_rate_rpm
	_hitscan(0.0, data.melee_range)
	_melee_swing()
	fired.emit()


func _camera_ref() -> Camera3D:
	if _camera == null or not is_instance_valid(_camera):
		_camera = get_viewport().get_camera_3d()
		if _camera != null:
			_default_fov = DEFAULT_FOV
	return _camera


func _hitscan(spread_deg: float, override_range: float = -1.0) -> void:
	var cam := _camera_ref()
	if cam == null:
		return
	var basis := cam.global_transform.basis
	var dir := -basis.z
	if spread_deg > 0.0:
		var ang := deg_to_rad(spread_deg)
		dir = dir.rotated(basis.y.normalized(), randf_range(-ang, ang))
		dir = dir.rotated(basis.x.normalized(), randf_range(-ang, ang))
	var reach := override_range if override_range > 0.0 else data.max_range
	var from := cam.global_position
	var to := from + dir.normalized() * reach

	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = false
	if _player != null:
		query.exclude = [_player.get_rid()]

	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return
	var collider = hit.collider
	if collider != null and collider.has_method("take_damage"):
		var dist := from.distance_to(hit.position)
		collider.take_damage(_damage_at(dist), hit.position, hit.get("normal"))


func _damage_at(distance: float) -> float:
	var start := data.falloff_start * _eff_range_mult
	var end := data.falloff_end * _eff_range_mult
	var base: float
	if distance <= start:
		base = data.damage_near
	elif distance >= end:
		base = data.damage_far
	else:
		var t := (distance - start) / maxf(0.001, end - start)
		base = lerpf(data.damage_near, data.damage_far, t)
	return base * _eff_damage_mult


func _show_muzzle_flash() -> void:
	flash.restart()
	flash.emitting = true
	flash_light.light_energy = 3.0


func _melee_swing() -> void:
	if _view_model == null:
		return
	var start := Vector3.ZERO
	var tween := create_tween()
	tween.tween_property(_view_model, "position:z", -0.25, 0.06)
	tween.tween_property(_view_model, "position:z", start.z, 0.14)


func _kick() -> void:
	if _player == null or not _player.has_method("apply_recoil"):
		return
	var vertical := _eff_recoil_v * randf_range(0.9, 1.1)
	var horizontal := _eff_recoil_h * (sin(_shot_index * 1.3) + randf_range(-0.4, 0.4))
	_player.apply_recoil(vertical, horizontal)


# ---------------------------------------------------------------- reload

func _start_reload() -> void:
	if _reloading or _mag == _eff_mag or _reserve <= 0:
		return
	_reloading = true
	_reload_timer = _eff_reload
	reload_started.emit(_eff_reload)


func _finish_reload() -> void:
	_reloading = false
	var needed := _eff_mag - _mag
	var taken := mini(needed, _reserve)
	_mag += taken
	_reserve -= taken
	ammo_changed.emit(_mag, _reserve)
