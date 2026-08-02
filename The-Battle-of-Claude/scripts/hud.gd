extends CanvasLayer
## FPS HUD: crosshair, ammo counter, health bar. Binds to the player and its
## weapon by group and updates from their signals.

@onready var ammo_label: Label = $Ammo
@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthBar/Value

var _weapon: Node


func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player != null:
		player.health_changed.connect(_on_health_changed)
		_on_health_changed(player.get_health(), player.max_health)

	_weapon = get_tree().get_first_node_in_group("weapon")
	if _weapon != null:
		_weapon.ammo_changed.connect(_on_ammo_changed)
		_weapon.reload_started.connect(_on_reload_started)
		var ammo: Vector2i = _weapon.current_ammo()
		_on_ammo_changed(ammo.x, ammo.y)


func _on_ammo_changed(mag: int, reserve: int) -> void:
	ammo_label.text = "%d / %d" % [mag, reserve]


func _on_reload_started(_duration: float) -> void:
	ammo_label.text = "RELOADING"


func _on_health_changed(current: float, maximum: float) -> void:
	health_bar.max_value = maximum
	health_bar.value = current
	health_label.text = "%d" % roundi(current)
