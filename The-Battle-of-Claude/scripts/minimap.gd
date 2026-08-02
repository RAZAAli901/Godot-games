extends Control
## Tab-hold 2D minimap. While the "minimap" action is held, draws a
## player-centred, north-up radar: white = player, blue = allies, red = enemies.
## Forward (-Z) points up. Custom-drawn (no SubViewport) for cheapness.

@export var world_range: float = 130.0 # metres from centre to edge
@export var radius: float = 240.0      # pixels

var _player: CharacterBody3D


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_player = get_tree().get_first_node_in_group("player")


func _process(_delta: float) -> void:
	var want := Input.is_action_pressed("minimap")
	if want != visible:
		visible = want
	if visible:
		queue_redraw()


func _draw() -> void:
	var c := size * 0.5
	draw_circle(c, radius, Color(0.02, 0.04, 0.03, 0.55))
	draw_arc(c, radius, 0.0, TAU, 72, Color(0.45, 0.6, 0.45, 0.7), 2.0)

	if _player == null or not is_instance_valid(_player):
		return
	var origin := Vector2(_player.global_position.x, _player.global_position.z)
	var my_team: int = _player.get_team()

	for n in get_tree().get_nodes_in_group("combatant"):
		if n == _player or not is_instance_valid(n):
			continue
		if n.has_method("is_alive") and not n.is_alive():
			continue
		var rel := Vector2(n.global_position.x, n.global_position.z) - origin
		if rel.length() > world_range:
			continue
		var p := c + rel / world_range * radius
		var col := Color(0.4, 0.6, 1.0) if n.get_team() == my_team else Color(1.0, 0.35, 0.3)
		draw_circle(p, 4.0, col)

	# Player facing wedge (forward = -Z -> up).
	var fwd := -_player.global_transform.basis.z
	var fwd2 := Vector2(fwd.x, fwd.z).normalized()
	draw_line(c, c + fwd2 * 16.0, Color(1, 1, 1), 2.0)
	draw_circle(c, 5.0, Color(1, 1, 1))
