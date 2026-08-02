extends RefCounted
class_name Sfx
## Procedural gunshot generator — a placeholder so weapons are audible without
## external assets. Real Freesound/Pixabay clips can be assigned to
## WeaponData.fire_sound to override this per weapon (see ASSETS_CREDITS.md).
##
## Each shot is a short burst of noise (the "crack") plus a low sine "thump",
## shaped by an exponential decay envelope. Category tweaks length/decay/pitch
## so an SMG snaps, a shotgun booms and a sniper has a long tail.

const RATE := 44100

# category -> [duration_s, noise_decay, thump_hz, thump_decay, noise_mix]
const PROFILES := {
	"AR": [0.16, 26.0, 95.0, 26.0, 0.7],
	"SMG": [0.11, 34.0, 120.0, 32.0, 0.72],
	"Shotgun": [0.30, 12.0, 65.0, 14.0, 0.6],
	"LMG": [0.20, 20.0, 80.0, 20.0, 0.72],
	"Sniper": [0.42, 9.0, 55.0, 10.0, 0.65],
	"Pistol": [0.13, 30.0, 110.0, 28.0, 0.7],
	"Knife": [0.10, 40.0, 220.0, 45.0, 0.4],
}


static func gunshot(category: String) -> AudioStreamWAV:
	var p: Array = PROFILES.get(category, PROFILES["AR"])
	var duration: float = p[0]
	var noise_decay: float = p[1]
	var thump_hz: float = p[2]
	var thump_decay: float = p[3]
	var noise_mix: float = p[4]

	var count := int(RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(count * 2)

	# A tiny random-walk low-pass on the noise stops it sounding like pure hiss.
	var prev := 0.0
	for i in count:
		var t := float(i) / float(RATE)
		var env := exp(-t * noise_decay)
		var white := randf_range(-1.0, 1.0)
		prev = lerpf(prev, white, 0.5)
		var thump := sin(TAU * thump_hz * t) * exp(-t * thump_decay)
		var s := clampf((prev * noise_mix + thump * (1.0 - noise_mix)) * env, -1.0, 1.0)
		var v := int(s * 32767.0)
		bytes.encode_s16(i * 2, v)

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = RATE
	wav.stereo = false
	wav.data = bytes
	return wav
