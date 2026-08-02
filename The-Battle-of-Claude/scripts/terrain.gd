extends Node3D
## Greybox test arena. The large ground plane lives in the scene; cover blocks,
## ramps, distant "ruin" hills and shooting targets are spawned procedurally so
## the layout is easy to tune. Targets sit at increasing range to exercise the
## weapon's damage falloff.

const TargetScene: PackedScene = preload("res://scenes/world/target_dummy.tscn")

const COVER_COLOR := Color(0.30, 0.31, 0.28)
const HILL_COLOR := Color(0.24, 0.22, 0.19)


func _ready() -> void:
	_build_cover()
	_build_ramps()
	_build_hills()
	_spawn_targets()


func _make_box(size: Vector3, pos: Vector3, rot_y: float = 0.0, color: Color = COVER_COLOR) -> StaticBody3D:
	var body := StaticBody3D.new()

	var mesh := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.92
	mesh.mesh = box_mesh
	mesh.material_override = mat
	body.add_child(mesh)

	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)

	body.position = pos
	body.rotation.y = rot_y
	add_child(body)
	return body


func _build_cover() -> void:
	# Crates and low walls scattered around spawn for movement/peek testing.
	var layout := [
		{"size": Vector3(2, 2, 2), "pos": Vector3(-6, 1, -8)},
		{"size": Vector3(2, 2, 2), "pos": Vector3(5, 1, -10)},
		{"size": Vector3(6, 3, 0.6), "pos": Vector3(0, 1.5, -18), "rot": 0.0},
		{"size": Vector3(0.6, 3, 6), "pos": Vector3(-10, 1.5, -22), "rot": 0.0},
		{"size": Vector3(3, 1, 3), "pos": Vector3(9, 0.5, -24)},
		{"size": Vector3(2, 4, 2), "pos": Vector3(-3, 2, -32)},
		{"size": Vector3(2, 2, 2), "pos": Vector3(7, 1, -40)},
		{"size": Vector3(5, 2.5, 0.6), "pos": Vector3(-8, 1.25, -46), "rot": 0.4},
	]
	for c in layout:
		_make_box(c["size"], c["pos"], c.get("rot", 0.0))


func _build_ramps() -> void:
	# Two tilted slabs as makeshift ramps.
	_make_box(Vector3(4, 0.4, 6), Vector3(-14, 1.0, -12), 0.0).rotation.x = -0.35
	_make_box(Vector3(4, 0.4, 6), Vector3(12, 1.0, -16), 0.0).rotation.x = -0.30


func _build_hills() -> void:
	# Distant blocky masses standing in for the mountain-ruins skyline.
	_make_box(Vector3(40, 30, 40), Vector3(-90, 12, -140), 0.6, HILL_COLOR)
	_make_box(Vector3(60, 45, 50), Vector3(80, 18, -190), -0.3, HILL_COLOR)
	_make_box(Vector3(35, 22, 35), Vector3(10, 8, -240), 0.2, HILL_COLOR)


func _spawn_targets() -> void:
	# Increasing range so damage falloff is visible (near 30 -> far 18 for the AR).
	var spots := [
		Vector3(-2, 0, -10),
		Vector3(3, 0, -25),
		Vector3(-4, 0, -45),
		Vector3(2, 0, -70),
	]
	for spot in spots:
		var t := TargetScene.instantiate()
		add_child(t)
		t.position = spot
