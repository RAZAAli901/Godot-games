extends Node3D
## Attached to the root of the imported Western Frontier map. The source GLB
## is a plain visual scene with no collision, so on load we walk every
## MeshInstance3D in it and bake a StaticBody3D + trimesh CollisionShape3D for
## it automatically (Godot's built-in MeshInstance3D.create_trimesh_collision,
## the same thing "Mesh > Create Trimesh Static Body" does in the editor).
##
## This runs once at startup. With ~1500 meshes in the demo scene it takes a
## moment (a short hitch on load, not every frame) — that's expected. If you
## want faster subsequent loads, you can instead do this once in the editor
## (select the imported scene's root > Mesh > Create Trimesh Static Body) and
## then delete this script; either approach works.

@export var generate_on_ready: bool = true


func _ready() -> void:
	if generate_on_ready:
		_generate_collision(self)
		print("[MapCollisionGen] collision generation done.")


func _generate_collision(node: Node) -> void:
	if node is MeshInstance3D:
		var mi := node as MeshInstance3D
		if mi.mesh != null:
			mi.create_trimesh_collision()
	for child in node.get_children():
		_generate_collision(child)
