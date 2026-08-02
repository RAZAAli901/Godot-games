extends CharacterBody3D
class_name Bot
## AI combatant. Acquires the nearest enemy combatant (player or opposing bot),
## paths toward it with a NavigationAgent3D when out of range or without line of
## sight, and stops to face and hitscan-fire when it can see a target in range.
## Takes damage like any target and reports death to the match manager.

signal died(bot)

@export var team: int = 1
@export var max_health: float = 100.0
@export var move_speed: float = 4.5
@export var engage_range: float = 45.0
@export var sight_range: float = 130.0
@export var fire_interval: float = 0.7
@export var damage: float = 16.0
## 1.0 = perfect aim; lower widens the random spread cone.
@export var accuracy: float = 0.9

var _health: float
var _target: Node3D
var _retarget_timer: float = 0.0
var _fire_timer: float = 0.0
var _alive: bool = true
var _gravity: float = 9.8
var _material: StandardMaterial3D

@onready var agent: NavigationAgent3D = $Agent
@onready var mesh: MeshInstance3D = $Mesh
@onready var collision: CollisionShape3D = $Collision
@onready var eyes: Marker3D = $Eyes
@onready var audio: AudioStreamPlayer3D = $Audio


func _ready() -> void:
	add_to_group("bot")
	add_to_group("combatant")
	_health = max_health
	_gravity = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)
	agent.path_desired_distance = 1.0
	agent.target_desired_distance = 2.0
	audio.stream = Sfx.gunshot("SMG")
	_material = mesh.get_active_material(0).duplicate()
	mesh.material_override = _material
	_apply_team_color()


func get_team() -> int:
	return team


func is_alive() -> bool:
	return _alive


func _apply_team_color() -> void:
	# Team 0 = blue allies, others = red enemies.
	var c := Color(0.3, 0.5, 0.95) if team == 0 else Color(0.9, 0.3, 0.25)
	_material.albedo_color = c


func _physics_process(delta: float) -> void:
	if not _alive:
		return

	if not is_on_floor():
		velocity.y -= _gravity * delta

	_retarget_timer -= delta
	if _retarget_timer <= 0.0:
		_acquire_target()
		_retarget_timer = 0.5

	if _target != null and is_instance_valid(_target):
		_combat(delta)
	else:
		_decelerate(delta)

	move_and_slide()


func _combat(delta: float) -> void:
	var to_target := _target.global_position - global_position
	var dist := to_target.length()
	if dist <= engage_range and _has_line_of_sight():
		_decelerate(delta)
		_face(_target.global_position)
		_fire_timer -= delta
		if _fire_timer <= 0.0:
			_shoot()
			_fire_timer = fire_interval
	else:
		agent.target_position = _target.global_position
		_move_along_path()


func _move_along_path() -> void:
	if agent.is_navigation_finished():
		return
	var next := agent.get_next_path_position()
	var dir := next - global_position
	dir.y = 0.0
	if dir.length_squared() < 0.0001:
		return
	dir = dir.normalized()
	velocity.x = dir.x * move_speed
	velocity.z = dir.z * move_speed
	_face(global_position + dir)


func _decelerate(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, move_speed * 6.0 * delta)
	velocity.z = move_toward(velocity.z, 0.0, move_speed * 6.0 * delta)


func _face(point: Vector3) -> void:
	var flat := Vector3(point.x, global_position.y, point.z)
	if flat.distance_to(global_position) > 0.05:
		look_at(flat, Vector3.UP)


func _acquire_target() -> void:
	var best: Node3D = null
	var best_dist := sight_range
	for c in get_tree().get_nodes_in_group("combatant"):
		if c == self or not is_instance_valid(c):
			continue
		if not c.has_method("get_team") or c.get_team() == team:
			continue
		if c.has_method("is_alive") and not c.is_alive():
			continue
		var d := global_position.distance_to(c.global_position)
		if d < best_dist:
			best_dist = d
			best = c
	_target = best


func _has_line_of_sight() -> bool:
	if _target == null:
		return false
	var from := eyes.global_position
	var to := _target.global_position + Vector3.UP * 1.1
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return true # clear line to a target that is essentially point-blank
	return hit.collider == _target


func _shoot() -> void:
	audio.play()
	var from := eyes.global_position
	var aim := _target.global_position + Vector3.UP * 1.1
	var dir := (aim - from).normalized()
	var spread := (1.0 - clampf(accuracy, 0.0, 1.0)) * 0.15
	dir = dir.rotated(Vector3.UP, randf_range(-spread, spread))
	dir = dir.rotated(global_transform.basis.x.normalized(), randf_range(-spread, spread))

	var query := PhysicsRayQueryParameters3D.create(from, from + dir * engage_range * 1.5)
	query.exclude = [get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return
	var col = hit.collider
	if col != null and col.has_method("take_damage"):
		# Avoid friendly fire: only damage combatants on another team (or
		# non-combatant targets like the practice dummies).
		if col.has_method("get_team") and col.get_team() == team:
			return
		col.take_damage(damage, hit.position, hit.get("normal"))


func take_damage(amount: float, _pos: Vector3 = Vector3.ZERO, _normal: Variant = null) -> void:
	if not _alive:
		return
	_health -= amount
	_flash()
	if _health <= 0.0:
		_die()


func _flash() -> void:
	_material.emission_enabled = true
	_material.emission = Color(1, 1, 1)
	_material.emission_energy_multiplier = 0.6
	var tween := create_tween()
	tween.tween_property(_material, "emission_energy_multiplier", 0.0, 0.2)


func _die() -> void:
	_alive = false
	velocity = Vector3.ZERO
	collision.disabled = true
	# Topple over to read as "down".
	mesh.rotation_degrees.x = 90.0
	mesh.position.y = 0.4
	died.emit(self)
