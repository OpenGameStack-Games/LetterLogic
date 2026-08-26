# tests/test_stats_manager.gd
extends "res://tests/test_base.gd"

## Automated unit tests for StatsManager and StatsScreen UI.

const StatsManagerScript = preload("res://autoloads/stats_manager.gd")
const StatsScreenScript = preload("res://scripts/stats_screen.gd")
const GameManagerScript = preload("res://autoloads/game_manager.gd")

const TEST_STATS_PATH: String = "user://test_stats.json"

var stats_mgr: Node = null

func _init() -> void:
	stats_mgr = StatsManagerScript.new()
	stats_mgr.reset_all_stats(TEST_STATS_PATH)

func cleanup() -> void:
	if stats_mgr != null and is_instance_valid(stats_mgr):
		stats_mgr.reset_all_stats(TEST_STATS_PATH)
		stats_mgr.free()
		stats_mgr = null

func test_record_win_and_loss() -> void:
	# Initial stats should be 0
	var stats_init: Dictionary = stats_mgr.get_stats_for_mode(GameManagerScript.GameMode.CONTINUOUS)
	assert_eq(int(stats_init.get("played", -1)), 0, "Initial played games should be 0")
	assert_eq(int(stats_init.get("won", -1)), 0, "Initial won games should be 0")
	
	# Record Win in 3 attempts
	stats_mgr.record_game(GameManagerScript.GameMode.CONTINUOUS, true, 3, TEST_STATS_PATH)
	var stats_win: Dictionary = stats_mgr.get_stats_for_mode(GameManagerScript.GameMode.CONTINUOUS)
	assert_eq(int(stats_win.get("played", 0)), 1, "Played games should be 1")
	assert_eq(int(stats_win.get("won", 0)), 1, "Won games should be 1")
	assert_eq(int(stats_win.get("current_streak", 0)), 1, "Current streak should be 1")
	assert_eq(int(stats_win.get("max_streak", 0)), 1, "Max streak should be 1")
	assert_eq(int(stats_win.get("distribution", {}).get("3", 0)), 1, "Distribution for 3 attempts should be 1")
	assert_eq(stats_mgr.get_win_percentage(GameManagerScript.GameMode.CONTINUOUS), 100, "Win % should be 100")
	
	# Record Loss
	stats_mgr.record_game(GameManagerScript.GameMode.CONTINUOUS, false, 0, TEST_STATS_PATH)
	var stats_loss: Dictionary = stats_mgr.get_stats_for_mode(GameManagerScript.GameMode.CONTINUOUS)
	assert_eq(int(stats_loss.get("played", 0)), 2, "Played games should be 2")
	assert_eq(int(stats_loss.get("won", 0)), 1, "Won games should remain 1")
	assert_eq(int(stats_loss.get("current_streak", 0)), 0, "Current streak should reset to 0 on loss")
	assert_eq(int(stats_loss.get("max_streak", 0)), 1, "Max streak should remain 1")
	assert_eq(int(stats_loss.get("distribution", {}).get("loss", 0)), 1, "Distribution for loss should be 1")
	assert_eq(stats_mgr.get_win_percentage(GameManagerScript.GameMode.CONTINUOUS), 50, "Win % should be 50")

func test_mode_isolation() -> void:
	stats_mgr.reset_all_stats(TEST_STATS_PATH)
	# Record in Daily
	stats_mgr.record_game(GameManagerScript.GameMode.DAILY, true, 4, TEST_STATS_PATH)
	
	var daily_stats: Dictionary = stats_mgr.get_stats_for_mode(GameManagerScript.GameMode.DAILY)
	var cont_stats: Dictionary = stats_mgr.get_stats_for_mode(GameManagerScript.GameMode.CONTINUOUS)
	
	assert_eq(int(daily_stats.get("played", 0)), 1, "Daily played should be 1")
	assert_eq(int(cont_stats.get("played", 0)), 0, "Continuous played should remain 0")

func test_stats_screen_ui() -> void:
	var scn: PackedScene = load("res://scenes/stats_screen.tscn") as PackedScene
	assert_true(scn != null, "stats_screen.tscn should load")
	
	var screen: Node = scn.instantiate()
	assert_true(screen != null, "stats_screen should instantiate")
	
	screen.call("set_mode", GameManagerScript.GameMode.DAILY)
	var dist_box: Node = screen.find_child("DistributionContainer", true, false)
	assert_true(dist_box != null, "DistributionContainer should exist in StatsScreen")
	assert_eq(dist_box.get_child_count(), 7, "DistributionContainer should render 7 rows (1..6 + loss)")
	
	screen.free()
