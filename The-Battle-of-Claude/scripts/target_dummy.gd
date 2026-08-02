extends StaticBody3D
class_name TargetDummy
## Greybox shooting target. Implements take_damage() so the weapon hitscan can
## register hits. Flashes on hit, drops when destroyed, respawns after a delay
## so the arena stays testable.

@export var max_health: float = 100.0
@export var respawn_delay: float = 3.0

var _health: float
var _flash: float = 0.0
var _dead: bool = false
var _respawn_timer: float = 0.0

@onready var mesh: MeshInstance3D = $Mesh
@onready var collision: CollisionShape3D = $Collision
@onready var _material: StandardMaterial3D = mesh.get_active_material(0).duplicate()


func _ready() -> void:
	add_to_group("target")
	mesh.material_override = _material
	_health = max_health


func _process(delta: float) -> void:
	if _flash > 0.0:
		_flash = maxf(0.0, _flash - delta * 5.0)
		_material.emission_energy_multiplier = _flash * 6.0

	if _dead:
		_respawn_timer -= delta
		if _respawn_timer <= 0.0:
			_respawn()


func take_damage(amount: float, _pos: Vector3 = Vector3.ZERO, _normal: Variant = null) -> void:
	if _dead:
		return
	_health -= amount
	_flash = 1.0
	_material.emission = Color(1.0, 0.2, 0.15)
	if _health <= 0.0:
		_die()


func _die() -> void:
	_dead = true
	_respawn_timer = respawn_delay
	mesh.visible = false
	collision.disabled = true


func _respawn() -> void:
	_dead = false
	_health = max_health
	mesh.visible = true
	collision.disabled = false
