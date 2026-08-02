extends Node3D
## Greybox test arena. Ground, cover blocks, ramps and distant "ruin" hills are
## nested under a NavigationRegion3D and a navmesh is baked over the play area so
## bots can path and route around cover. Targets sit at increasing range to
## exercise weapon falloff.

const TargetScene: PackedScene = preload("res://scenes/world/target_dummy.tscn")

const COVER_COLOR := Color(0.30, 0.31, 0.28)
const HILL_COLOR := Color(0.24, 0.22, 0.19)
const GROUND_COLOR := Color(0.52, 0.5, 0.44)

var nav_region: NavigationRegion3D


func _ready() -> void:
	nav_region = NavigationRegion3D.new()
	add_child(nav_region)
	_build_ground()
	_build_cover()
	_build_ramps()
	_build_hills()
	_spawn_targets()
	_bake_nav()


func _build_ground() -> void:
	var body := StaticBody3D.new()

	var mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(1500, 1500)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = GROUND_COLOR
	mat.roughness = 0.9
	mat.uv1_scale = Vector3(150, 150, 1)
	mesh.mesh = plane
	mesh.material_override = mat
	body.add_child(mesh)

	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1500, 2, 1500)
	col.shape = shape
	col.position = Vector3(0, -1, 0)
	body.add_child(col)

	nav_region.add_child(body)


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
	nav_region.add_child(body)
	return body


func _build_cover() -> void:
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
	_make_box(Vector3(4, 0.4, 6), Vector3(-14, 1.0, -12), 0.0).rotation.x = -0.35
	_make_box(Vector3(4, 0.4, 6), Vector3(12, 1.0, -16), 0.0).rotation.x = -0.30


func _build_hills() -> void:
	_make_box(Vector3(40, 30, 40), Vector3(-90, 12, -140), 0.6, HILL_COLOR)
	_make_box(Vector3(60, 45, 50), Vector3(80, 18, -190), -0.3, HILL_COLOR)
	_make_box(Vector3(35, 22, 35), Vector3(10, 8, -240), 0.2, HILL_COLOR)


func _spawn_targets() -> void:
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


func _bake_nav() -> void:
	var nm := NavigationMesh.new()
	nm.agent_radius = 0.5
	nm.agent_height = 1.8
	nm.agent_max_climb = 0.5
	nm.agent_max_slope = 45.0
	nm.cell_size = 0.25
	nm.cell_height = 0.25
	# Parse mesh instances: works at _ready without waiting for the physics
	# server to register colliders (collider parsing bakes 0 polys pre-physics).
	nm.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_MESH_INSTANCES
	nm.geometry_source_geometry_mode = NavigationMesh.SOURCE_GEOMETRY_ROOT_NODE_CHILDREN
	# Bound the bake to the play area so we don't mesh the whole 1.5 km ground.
	nm.filter_baking_aabb = AABB(Vector3(-120, -3, -250), Vector3(240, 30, 260))

	nav_region.navigation_mesh = nm
	# Synchronous bake so the navmesh is ready before bots spawn. (Godot logs a
	# one-time note that runtime mesh parsing is used — harmless here.)
	nav_region.bake_navigation_mesh(false)
