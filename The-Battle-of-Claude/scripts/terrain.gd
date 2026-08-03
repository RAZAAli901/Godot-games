extends Node3D
## Greybox test arena. Ground, cover blocks, ramps and distant "ruin" hills are
## nested under a NavigationRegion3D and a navmesh is baked over the play area so
## bots can path and route around cover. Targets sit at increasing range to
## exercise weapon falloff.

const TargetScene: PackedScene = preload("res://scenes/world/target_dummy.tscn")

const COVER_COLOR := Color(0.30, 0.31, 0.28)
const HILL_COLOR := Color(0.24, 0.22, 0.19)
const GROUND_COLOR := Color(0.52, 0.5, 0.44)
const RUIN_COLOR := Color(0.4, 0.38, 0.35)
const ROAD_COLOR := Color(0.13, 0.13, 0.14)
const FOLIAGE_COLOR := Color(0.24, 0.34, 0.16)

var nav_region: NavigationRegion3D
var _detail: Node3D


func _ready() -> void:
	nav_region = NavigationRegion3D.new()
	add_child(nav_region)
	_detail = Node3D.new()
	add_child(_detail)
	_build_ground()
	_build_cover()
	_build_ramps()
	_build_hills()
	_build_ruins()      # walls become nav obstacles -> bake after
	_bake_nav()
	_build_roads()      # visual only
	_scatter_foliage()  # multimesh, no collision
	_scatter_debris()
	_scatter_nature_test_area() # test cluster of Quaternius stylized nature props
	_spawn_targets()


func _scatter_nature_test_area() -> void:
	var test_origin := Vector3(0, 0, -12) # right in front of player spawn
	var tree_scene: PackedScene = load("res://assets/models/nature/BirchTree_1.tscn")
	var bush_scene: PackedScene = load("res://assets/models/nature/Bush.tscn")
	var rock_scene: PackedScene = load("res://assets/models/nature/Rock_1.tscn")
	
	if tree_scene != null:
		for i in 8:
			var tree = tree_scene.instantiate()
			tree.position = test_origin + Vector3(randf_range(-14, 14), 0, randf_range(-15, 5))
			tree.rotation.y = randf() * TAU
			_detail.add_child(tree)
			
	if bush_scene != null:
		for i in 15:
			var bush = bush_scene.instantiate()
			bush.position = test_origin + Vector3(randf_range(-18, 18), 0, randf_range(-18, 5))
			bush.rotation.y = randf() * TAU
			_detail.add_child(bush)
			
	if rock_scene != null:
		for i in 6:
			var rock = rock_scene.instantiate()
			rock.position = test_origin + Vector3(randf_range(-12, 12), 0, randf_range(-12, 5))
			rock.rotation.y = randf() * TAU
			_detail.add_child(rock)




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


func _visual_box(size: Vector3, pos: Vector3, color: Color, rot_y: float = 0.0) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.95
	mesh.mesh = box
	mesh.material_override = mat
	mesh.position = pos
	mesh.rotation.y = rot_y
	_detail.add_child(mesh)
	return mesh


func _build_ruins() -> void:
	# A few broken building shells (walls with a doorway gap). Static -> nav
	# obstacles, so bots route through the openings.
	for r in [
		{"c": Vector3(-24, 0, -30), "w": 10.0, "d": 8.0, "h": 4.0, "rot": 0.2},
		{"c": Vector3(22, 0, -55), "w": 12.0, "d": 9.0, "h": 5.0, "rot": -0.3},
		{"c": Vector3(-2, 0, -85), "w": 14.0, "d": 10.0, "h": 4.5, "rot": 0.1},
	]:
		_ruin(r["c"], r["w"], r["d"], r["h"], r["rot"])


func _ruin(center: Vector3, w: float, d: float, h: float, rot_y: float) -> void:
	var t := 0.5
	var basis := Basis(Vector3.UP, rot_y)
	var parts := [
		{"size": Vector3(w, h, t), "off": Vector3(0, h * 0.5, -d * 0.5)},          # back
		{"size": Vector3(t, h, d), "off": Vector3(-w * 0.5, h * 0.5, 0)},          # left
		{"size": Vector3(t, h * 0.7, d), "off": Vector3(w * 0.5, h * 0.35, 0)},    # right (broken)
		{"size": Vector3(w * 0.34, h, t), "off": Vector3(-w * 0.33, h * 0.5, d * 0.5)}, # front-left
		{"size": Vector3(w * 0.34, h * 0.55, t), "off": Vector3(w * 0.33, h * 0.28, d * 0.5)}, # front-right (broken)
	]
	for p in parts:
		var pos: Vector3 = center + basis * p["off"]
		_make_box(p["size"], pos, rot_y, RUIN_COLOR)


func _build_roads() -> void:
	# Flat asphalt strips (visual only).
	_visual_box(Vector3(7, 0.06, 230), Vector3(0, 0.03, -100), ROAD_COLOR)
	_visual_box(Vector3(120, 0.06, 6), Vector3(0, 0.03, -50), ROAD_COLOR, 0.15)


func _scatter_foliage() -> void:
	var bush := CylinderMesh.new()
	bush.top_radius = 0.0
	bush.bottom_radius = 0.45
	bush.height = 1.0
	var mat := StandardMaterial3D.new()
	mat.albedo_color = FOLIAGE_COLOR
	mat.roughness = 1.0
	bush.material = mat

	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = bush
	var count := 500
	mm.instance_count = count
	for i in count:
		var pos := Vector3(randf_range(-90, 90), 0.5, randf_range(-130, 25))
		var b := Basis(Vector3.UP, randf() * TAU).scaled(Vector3.ONE * randf_range(0.6, 1.5))
		mm.set_instance_transform(i, Transform3D(b, pos))

	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_detail.add_child(mmi)


func _scatter_debris() -> void:
	# Small rubble chunks (visual only) so bots don't snag on them.
	for i in 30:
		var s := randf_range(0.3, 0.9)
		var pos := Vector3(randf_range(-60, 60), s * 0.5, randf_range(-110, 10))
		_visual_box(Vector3(s, s, s), pos, COVER_COLOR.darkened(0.1), randf() * TAU)


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
