extends Node
class_name MatchManager
## Runs the team deathmatch. Spawns team_size per side (allies = team 0 with the
## player, enemies = team 1), tracks alive counts, respawns the player on death,
## and ends the match when a whole team is down. team_size comes from the
## project config value so it is tunable toward 20v20 later.

const BotScene: PackedScene = preload("res://scenes/bot.tscn")

signal counts_changed(allies: int, enemies: int)
signal match_ended(player_won: bool)

var team_size: int = 8
var _player: CharacterBody3D
var _player_spawn: Vector3
var _ended: bool = false


func _ready() -> void:
	add_to_group("match")
	team_size = int(ProjectSettings.get_setting("game/config/team_size", 8))
	_player = get_tree().get_first_node_in_group("player")
	if _player != null:
		_player_spawn = _player.global_position
		_player.died.connect(_on_player_died)
	# Wait a couple physics frames so the navmesh is registered on the map.
	await get_tree().physics_frame
	await get_tree().physics_frame
	_spawn_teams()


func _spawn_teams() -> void:
	for i in team_size - 1:
		_spawn_bot(0, _ally_spawn(i))
	for i in team_size:
		_spawn_bot(1, _enemy_spawn(i))
	_recount()


func _spawn_bot(team: int, pos: Vector3) -> void:
	var bot: Bot = BotScene.instantiate()
	bot.team = team
	get_parent().add_child(bot)
	bot.global_position = pos
	bot.died.connect(_on_bot_died)


func _ally_spawn(i: int) -> Vector3:
	return Vector3(-12 + (i % 4) * 8, 1.5, -6 - float(i / 4) * 6.0)


func _enemy_spawn(i: int) -> Vector3:
	return Vector3(-18 + (i % 4) * 12, 1.5, -95 - float(i / 4) * 8.0)


func _on_bot_died(_bot: Bot) -> void:
	_recount()


func _on_player_died() -> void:
	await get_tree().create_timer(2.0).timeout
	if _player != null and is_instance_valid(_player) and _player.has_method("respawn"):
		_player.respawn(_player_spawn)


func _recount() -> void:
	if _ended:
		return
	var allies := 0
	var enemies := 0
	for c in get_tree().get_nodes_in_group("bot"):
		if not c.is_alive():
			continue
		if c.get_team() == 0:
			allies += 1
		else:
			enemies += 1
	var player_up: bool = _player != null and _player.is_alive()
	if player_up:
		allies += 1
	counts_changed.emit(allies, enemies)

	if enemies == 0:
		_end(true)
	elif allies == 0:
		_end(false)


func _end(player_won: bool) -> void:
	_ended = true
	match_ended.emit(player_won)
