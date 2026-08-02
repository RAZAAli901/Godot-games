extends VehicleBody3D
class_name Vehicle
## Drivable jeep. Press Interact (E) near it to get in; WASD to drive (W/S
## throttle, A/D steer, Space brake), Interact again to get out. Runs a looping
## engine sound whose pitch tracks speed, and rams combatants at speed.

@export var max_engine_force: float = 420.0
@export var max_steer: float = 0.5
@export var max_brake: float = 6.0
@export var enter_distance: float = 4.5
@export var ram_damage: float = 45.0
@export var ram_min_speed: float = 5.0

var _occupant: CharacterBody3D
var _driving: bool = false

@onready var seat_camera: Camera3D = $SeatCamera
@onready var exit_point: Marker3D = $ExitPoint
@onready var engine_audio: AudioStreamPlayer3D = $EngineAudio
@onready var ram: Area3D = $Ram


func _ready() -> void:
	add_to_group("vehicle")
	engine_audio.stream = Sfx.engine_loop()
	engine_audio.volume_db = -60.0
	engine_audio.play()
	ram.body_entered.connect(_on_ram_body)


func _physics_process(delta: float) -> void:
	if _driving:
		var throttle := Input.get_axis("move_back", "move_forward")
		engine_force = throttle * max_engine_force
		var steer_in := Input.get_axis("move_right", "move_left")
		steering = move_toward(steering, steer_in * max_steer, delta * 2.5)
		brake = max_brake if Input.is_action_pressed("jump") else 0.0

		var speed := linear_velocity.length()
		engine_audio.volume_db = lerpf(engine_audio.volume_db, -6.0, delta * 3.0)
		engine_audio.pitch_scale = 0.8 + clampf(speed * 0.04, 0.0, 1.6)

		if Input.is_action_just_pressed("interact"):
			_exit()
	else:
		engine_audio.volume_db = lerpf(engine_audio.volume_db, -60.0, delta * 2.0)
		_check_enter()


func _check_enter() -> void:
	if _occupant != null:
		return
	var p := get_tree().get_first_node_in_group("player")
	if p == null:
		return
	if p.global_position.distance_to(global_position) <= enter_distance \
			and Input.is_action_just_pressed("interact"):
		_enter(p)


func _enter(p: CharacterBody3D) -> void:
	_occupant = p
	_driving = true
	p.set_driving(true)
	seat_camera.current = true


func _exit() -> void:
	var p := _occupant
	_driving = false
	engine_force = 0.0
	brake = max_brake
	steering = 0.0
	seat_camera.current = false
	if p != null and is_instance_valid(p):
		p.set_driving(false)
		p.global_position = exit_point.global_position
	_occupant = null


func _on_ram_body(body: Node) -> void:
	if not _driving or body == _occupant:
		return
	if linear_velocity.length() < ram_min_speed:
		return
	if body.has_method("take_damage"):
		body.take_damage(ram_damage)
