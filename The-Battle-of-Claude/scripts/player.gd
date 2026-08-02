extends CharacterBody3D
## First-person player controller.
##
## The body node yaws (mouse X); the Head node pitches (mouse Y, clamped).
## Movement uses smoothed acceleration/deceleration with sprint, crouch and
## jump, plus velocity-driven head-bob so motion reads grounded, not floaty.

@export_group("Speed (m/s)")
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.5
@export var crouch_speed: float = 2.6

@export_group("Feel")
@export var jump_velocity: float = 4.8
@export var ground_accel: float = 55.0
@export var ground_decel: float = 65.0
@export var air_accel: float = 12.0

@export_group("Head-bob")
@export var bob_frequency: float = 2.0
@export var bob_amplitude: float = 0.055

@export_group("Recoil")
## How fast the view returns to aim after a recoil kick (higher = snappier).
@export var recoil_recovery: float = 9.0

@export_group("Health")
@export var max_health: float = 100.0

signal health_changed(current: float, maximum: float)
signal died()

const STAND_HEIGHT := 1.8
const CROUCH_HEIGHT := 1.1
const STAND_HEAD_Y := 1.6
const CROUCH_HEAD_Y := 0.95
const PITCH_LIMIT := 1.4 # radians (~80 degrees)

var _mouse_sens: float = 0.0025
var _gravity: float = 9.8
var _yaw: float = 0.0
var _pitch: float = 0.0
var _recoil: Vector2 = Vector2.ZERO # x = pitch add, y = yaw add (radians)
var _is_crouching: bool = false
var _bob_time: float = 0.0
var _base_cam_pos: Vector3
var _health: float = 100.0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var collision: CollisionShape3D = $Collision
@onready var capsule: CapsuleShape3D = collision.shape
@onready var ceiling_check: RayCast3D = $CeilingCheck


func _ready() -> void:
	add_to_group("player")
	_mouse_sens = ProjectSettings.get_setting("game/config/mouse_sensitivity", 0.0025)
	_gravity = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)
	_base_cam_pos = camera.position
	_yaw = rotation.y
	_health = max_health
	health_changed.emit(_health, max_health)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_yaw -= event.relative.x * _mouse_sens
		_pitch = clampf(_pitch - event.relative.y * _mouse_sens, -PITCH_LIMIT, PITCH_LIMIT)


## Called by the equipped weapon on each shot. Positive vertical = view kicks up.
func apply_recoil(vertical: float, horizontal: float) -> void:
	_recoil.x += vertical
	_recoil.y += horizontal


func take_damage(amount: float, _pos: Vector3 = Vector3.ZERO, _normal: Variant = null) -> void:
	if _health <= 0.0:
		return
	_health = maxf(0.0, _health - amount)
	health_changed.emit(_health, max_health)
	if _health <= 0.0:
		died.emit()


func get_health() -> float:
	return _health


func get_health_ratio() -> float:
	return _health / max_health if max_health > 0.0 else 0.0


func _update_aim(delta: float) -> void:
	_recoil = _recoil.lerp(Vector2.ZERO, 1.0 - exp(-recoil_recovery * delta))
	rotation.y = _yaw + _recoil.y
	head.rotation.x = _pitch + _recoil.x


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_jump()
	_handle_crouch(delta)
	_handle_movement(delta)
	move_and_slide()
	_update_aim(delta)
	_apply_head_bob(delta)


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta


func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor() and not _is_crouching:
		velocity.y = jump_velocity


func _handle_movement(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var wish_dir := (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()

	var horizontal := Vector3(velocity.x, 0.0, velocity.z)
	if wish_dir != Vector3.ZERO:
		var accel := ground_accel if is_on_floor() else air_accel
		horizontal = horizontal.move_toward(wish_dir * _current_speed(), accel * delta)
	else:
		horizontal = horizontal.move_toward(Vector3.ZERO, ground_decel * delta)

	velocity.x = horizontal.x
	velocity.z = horizontal.z


func _current_speed() -> float:
	if _is_crouching:
		return crouch_speed
	# Sprint only when actively pushing forward and grounded.
	if Input.is_action_pressed("sprint") and Input.is_action_pressed("move_forward") and is_on_floor():
		return sprint_speed
	return walk_speed


func _handle_crouch(delta: float) -> void:
	var want_crouch := Input.is_action_pressed("crouch")
	# Block standing up if something is directly overhead.
	if _is_crouching and not want_crouch and ceiling_check.is_colliding():
		want_crouch = true

	_is_crouching = want_crouch

	var target_height := CROUCH_HEIGHT if _is_crouching else STAND_HEIGHT
	var target_head_y := CROUCH_HEAD_Y if _is_crouching else STAND_HEAD_Y
	var lerp_w := 1.0 - exp(-12.0 * delta)

	capsule.height = lerpf(capsule.height, target_height, lerp_w)
	collision.position.y = capsule.height * 0.5
	head.position.y = lerpf(head.position.y, target_head_y, lerp_w)


func _apply_head_bob(delta: float) -> void:
	var speed := Vector3(velocity.x, 0.0, velocity.z).length()
	var target := _base_cam_pos
	if is_on_floor() and speed > 0.5:
		_bob_time += delta * speed
		target.y += sin(_bob_time * bob_frequency) * bob_amplitude
		target.x += cos(_bob_time * bob_frequency * 0.5) * bob_amplitude * 0.6
	camera.position = camera.position.lerp(target, 1.0 - exp(-10.0 * delta))
