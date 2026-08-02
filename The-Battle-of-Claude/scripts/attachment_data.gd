extends Resource
class_name AttachmentData
## One gunsmith attachment. Modifiers are multiplicative and fold onto the base
## WeaponData at equip time (see BRIEF.md GUNSMITH STAT DATA). Only one
## attachment per slot may be equipped at once.

@export var attachment_name: String = "Attachment"
## Slot type: "Optic", "Barrel", "Magazine", "Grip" or "Muzzle".
@export var slot: String = "Optic"

@export_group("Stat multipliers (1.0 = no change)")
@export var recoil_v_mult: float = 1.0
@export var recoil_h_mult: float = 1.0
## Multiplies ADS time. <1 = faster ADS, >1 = slower.
@export var ads_time_mult: float = 1.0
## Multiplies effective range (falloff distances) and, with it, ranged damage.
@export var range_mult: float = 1.0
## Multiplies flat damage (e.g. suppressor 0.9).
@export var damage_mult: float = 1.0
@export var mag_mult: float = 1.0
## Multiplies reload time. <1 = faster reload.
@export var reload_mult: float = 1.0
@export var move_mult: float = 1.0

@export_group("Special")
@export var no_muzzle_flash: bool = false
## Suppressor: quietens and lowers the pitch of the shot.
@export var audio_suppress: bool = false
