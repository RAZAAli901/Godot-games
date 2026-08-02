extends Node3D
class_name Weapon
## Hitscan weapon. Reads all balance from a WeaponData resource (.tres).
## Fires from the active camera's centre, applies range-based damage falloff,
## kicks the player's view with a climbing recoil pattern, and emits a muzzle
## flash. Ammo/reload state is surfaced via signals for the HUD.

@export var data: WeaponData

signal ammo_changed(mag: int, reserve: int)
signal fired()
signal reload_started(duration: float)

var _mag: int = 0
var _reserve: int = 0
var _cooldown: float = 0.0
var _reloading: bool = false
var _reload_timer: float = 0.0
var _shot_index: int = 0

@onready var muzzle: Marker3D = $Muzzle
@onready var flash: GPUParticles3D = $Muzzle/Flash
@onready var flash_light: OmniLight3D = $Muzzle/FlashLight

var _camera: Camera3D
var _player: CharacterBody3D


func _ready() -> void:
	if data == null:
		push_warning("Weapon has no WeaponData assigned.")
		return
	_mag = data.mag_size
	_reserve = data.mag_size * 6
	_player = get_tree().get_first_node_in_group("player")
	ammo_changed.emit(_mag, _reserve)


func _process(delta: float) -> void:
	if data == null:
		return
	_cooldown = maxf(0.0, _cooldown - delta)
	if flash_light.light_energy > 0.0:
		flash_light.light_energy = maxf(0.0, flash_light.light_energy - delta * 60.0)

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


func _can_fire() -> bool:
	return not _reloading and _cooldown <= 0.0 and _mag > 0


func _fire() -> void:
	_mag -= 1
	_shot_index += 1
	_cooldown = 60.0 / data.fire_rate_rpm
	_hitscan()
	_show_muzzle_flash()
	_kick()
	ammo_changed.emit(_mag, _reserve)
	fired.emit()
	if _mag == 0:
		_start_reload()


func _camera_ref() -> Camera3D:
	if _camera == null or not is_instance_valid(_camera):
		_camera = get_viewport().get_camera_3d()
	return _camera


func _hitscan() -> void:
	var cam := _camera_ref()
	if cam == null:
		return
	var from := cam.global_position
	var dir := -cam.global_transform.basis.z
	var to := from + dir * data.max_range

	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = false
	if _player != null:
		query.exclude = [_player.get_rid()]

	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return

	var collider = hit.collider
	var distance := from.distance_to(hit.position)
	if collider != null and collider.has_method("take_damage"):
		collider.take_damage(data.damage_at(distance), hit.position, hit.get("normal"))


func _show_muzzle_flash() -> void:
	flash.restart()
	flash.emitting = true
	flash_light.light_energy = 3.0


func _kick() -> void:
	if _player == null or not _player.has_method("apply_recoil"):
		return
	# Vertical always climbs; horizontal drifts side to side + a little noise so
	# the pattern is not a straight vertical line.
	var vertical := data.recoil_vertical * randf_range(0.9, 1.1)
	var horizontal := data.recoil_horizontal * (sin(_shot_index * 1.3) + randf_range(-0.4, 0.4))
	_player.apply_recoil(vertical, horizontal)


func _start_reload() -> void:
	if _reloading or _mag == data.mag_size or _reserve <= 0:
		return
	_reloading = true
	_reload_timer = data.reload_time
	reload_started.emit(data.reload_time)


func _finish_reload() -> void:
	_reloading = false
	var needed := data.mag_size - _mag
	var taken := mini(needed, _reserve)
	_mag += taken
	_reserve -= taken
	ammo_changed.emit(_mag, _reserve)
