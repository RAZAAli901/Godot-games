extends Control
## Simple four-line crosshair drawn in code so spread can be driven later
## (movement/ADS) without swapping textures.

@export var color: Color = Color(1, 1, 1, 0.85)
@export var gap: float = 5.0
@export var line_length: float = 10.0
@export var thickness: float = 2.0
@export var dot_radius: float = 1.0

var spread: float = 0.0 : set = _set_spread
var _hit: float = 0.0
var _hit_kill: bool = false


func _set_spread(v: float) -> void:
	spread = maxf(0.0, v)
	queue_redraw()


## Called by the HUD when the player's shot lands. killed = target dropped.
func flash_hit(killed: bool) -> void:
	_hit = 1.0
	_hit_kill = killed
	queue_redraw()


func _process(delta: float) -> void:
	if _hit > 0.0:
		_hit = maxf(0.0, _hit - delta * 4.0)
		queue_redraw()


func _draw() -> void:
	var c := size * 0.5
	var g := gap + spread
	# up, down, left, right
	draw_line(c + Vector2(0, -g), c + Vector2(0, -g - line_length), color, thickness)
	draw_line(c + Vector2(0, g), c + Vector2(0, g + line_length), color, thickness)
	draw_line(c + Vector2(-g, 0), c + Vector2(-g - line_length, 0), color, thickness)
	draw_line(c + Vector2(g, 0), c + Vector2(g + line_length, 0), color, thickness)
	if dot_radius > 0.0:
		draw_circle(c, dot_radius, color)

	# Hit marker: four diagonal ticks that fade out; red on a kill.
	if _hit > 0.0:
		var hit_color := Color(1, 0.3, 0.25, _hit) if _hit_kill else Color(1, 1, 1, _hit)
		var inner := 4.0
		var outer := 9.0
		for d in [Vector2(1, 1), Vector2(-1, 1), Vector2(1, -1), Vector2(-1, -1)]:
			draw_line(c + d * inner, c + d * outer, hit_color, 2.0)
