extends Control
## Simple four-line crosshair drawn in code so spread can be driven later
## (movement/ADS) without swapping textures.

@export var color: Color = Color(1, 1, 1, 0.85)
@export var gap: float = 5.0
@export var line_length: float = 10.0
@export var thickness: float = 2.0
@export var dot_radius: float = 1.0

var spread: float = 0.0 : set = _set_spread


func _set_spread(v: float) -> void:
	spread = maxf(0.0, v)
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
