# autoloads/stats_manager.gd
extends Node

## StatsManager AutoLoad
## Tracks and persists gameplay statistics (games played, win rates, streaks, guess distributions)
## completely segregated for Daily Challenge and Continuous Play modes.

const GameManagerScript = preload("res://autoloads/game_manager.gd")

const STATS_PATH: String = "user://stats.json"

var _stats_data: Dictionary = {
	"daily": {
		"played": 0,
		"won": 0,
		"current_streak": 0,
		"max_streak": 0,
		"distribution": { "1": 0, "2": 0, "3": 0, "4": 0, "5": 0, "6": 0, "loss": 0 }
	},
	"continuous": {
		"played": 0,
		"won": 0,
		"current_streak": 0,
		"max_streak": 0,
		"distribution": { "1": 0, "2": 0, "3": 0, "4": 0, "5": 0, "6": 0, "loss": 0 }
	}
}

signal stats_updated()

func _ready() -> void:
	load_stats()
	_connect_game_manager()

func _connect_game_manager() -> void:
	var gm: Node = get_node_or_null("/root/GameManager")
	if gm != null:
		if not gm.game_won.is_connected(_on_game_won):
			gm.game_won.connect(_on_game_won)
		if not gm.game_lost.is_connected(_on_game_lost):
			gm.game_lost.connect(_on_game_lost)

func _on_game_won(attempts: int, _secret: String) -> void:
	var gm: Node = get_node_or_null("/root/GameManager")
	var mode: int = gm.current_mode if gm != null else GameManagerScript.GameMode.CONTINUOUS
	record_game(mode, true, attempts)

func _on_game_lost(_secret: String) -> void:
	var gm: Node = get_node_or_null("/root/GameManager")
	var mode: int = gm.current_mode if gm != null else GameManagerScript.GameMode.CONTINUOUS
	record_game(mode, false, 0)

func _get_mode_key(mode: int) -> String:
	if mode == GameManagerScript.GameMode.DAILY:
		return "daily"
	return "continuous"

## Records the outcome of a game session.
func record_game(mode: int, won: bool, attempts: int, custom_path: String = "") -> void:
	var key: String = _get_mode_key(mode)
	var mode_stats: Dictionary = _stats_data[key]
	
	mode_stats["played"] = int(mode_stats.get("played", 0)) + 1
	
	var dist: Dictionary = mode_stats["distribution"]
	
	if won:
		mode_stats["won"] = int(mode_stats.get("won", 0)) + 1
		var new_streak: int = int(mode_stats.get("current_streak", 0)) + 1
		mode_stats["current_streak"] = new_streak
		if new_streak > int(mode_stats.get("max_streak", 0)):
			mode_stats["max_streak"] = new_streak
		
		var att_key: String = str(clampi(attempts, 1, 6))
		dist[att_key] = int(dist.get(att_key, 0)) + 1
	else:
		mode_stats["current_streak"] = 0
		dist["loss"] = int(dist.get("loss", 0)) + 1
	
	save_stats(custom_path)
	stats_updated.emit()
	print_debug("StatsManager: Recorded game in %s mode (Won: %s, Attempts: %d)" % [key, str(won), attempts])

## Returns the dictionary of statistics for the specified mode.
func get_stats_for_mode(mode: int) -> Dictionary:
	var key: String = _get_mode_key(mode)
	return _stats_data.get(key, {})

## Calculates and returns win percentage (0 to 100) for the specified mode.
func get_win_percentage(mode: int) -> int:
	var stats: Dictionary = get_stats_for_mode(mode)
	var played: int = int(stats.get("played", 0))
	var won: int = int(stats.get("won", 0))
	if played <= 0:
		return 0
	return int(round((float(won) / float(played)) * 100.0))

## Saves stats to disk as JSON.
func save_stats(custom_path: String = "") -> bool:
	var path: String = custom_path if custom_path != "" else STATS_PATH
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("StatsManager: Failed to open stats file '%s' for writing" % path)
		return false
	file.store_string(JSON.stringify(_stats_data, "\t"))
	file.close()
	return true

## Loads stats from disk.
func load_stats(custom_path: String = "") -> void:
	var path: String = custom_path if custom_path != "" else STATS_PATH
	if not FileAccess.file_exists(path):
		return
	
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return
	
	var text: String = file.get_as_text()
	file.close()
	
	var json: JSON = JSON.new()
	if json.parse(text) == OK and json.data is Dictionary:
		var loaded: Dictionary = json.data as Dictionary
		if loaded.has("daily") and loaded.has("continuous"):
			_stats_data = loaded

## Resets stats (useful for testing or user data wipe).
func reset_all_stats(custom_path: String = "") -> void:
	_stats_data = {
		"daily": {
			"played": 0, "won": 0, "current_streak": 0, "max_streak": 0,
			"distribution": { "1": 0, "2": 0, "3": 0, "4": 0, "5": 0, "6": 0, "loss": 0 }
		},
		"continuous": {
			"played": 0, "won": 0, "current_streak": 0, "max_streak": 0,
			"distribution": { "1": 0, "2": 0, "3": 0, "4": 0, "5": 0, "6": 0, "loss": 0 }
		}
	}
	var path: String = custom_path if custom_path != "" else STATS_PATH
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
