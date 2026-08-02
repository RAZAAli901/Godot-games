extends Resource
class_name WeaponData
## Tunable stats for one weapon. Stored as .tres so balance can be tuned
## without touching code (see WORKING RULES in BRIEF.md). Attachment modifiers
## (Phase 2) will be applied on top of these base values at equip time.

@export var weapon_name: String = "Weapon"
@export var category: String = "AR" # AR / SMG / Shotgun / LMG / Sniper / Pistol / Knife

@export_group("Damage")
@export var damage_near: float = 30.0
@export var damage_far: float = 18.0
## Distance (m) where damage starts dropping from near toward far.
@export var falloff_start: float = 40.0
## Distance (m) where damage reaches the far value; clamps beyond.
@export var falloff_end: float = 90.0

@export_group("Handling")
@export var fire_rate_rpm: float = 650.0
@export var mag_size: int = 30
@export var reload_time: float = 2.3
@export var ads_speed: float = 0.25
@export var automatic: bool = true
@export var max_range: float = 300.0

@export_group("Recoil (radians per shot)")
## Vertical climb per shot; horizontal is applied with alternating drift.
@export var recoil_vertical: float = 0.022
@export var recoil_horizontal: float = 0.010


func damage_at(distance: float) -> float:
	if distance <= falloff_start:
		return damage_near
	if distance >= falloff_end:
		return damage_far
	var t := (distance - falloff_start) / maxf(0.001, falloff_end - falloff_start)
	return lerpf(damage_near, damage_far, t)
