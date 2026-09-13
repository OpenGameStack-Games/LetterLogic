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
	stats_mgr.record_game(GameManagerScript.GameMode.CONTINUOUS, true, 3, 0.0, TEST_STATS_PATH)
	var stats_win: Dictionary = stats_mgr.get_stats_for_mode(GameManagerScript.GameMode.CONTINUOUS)
	assert_eq(int(stats_win.get("played", 0)), 1, "Played games should be 1")
	assert_eq(int(stats_win.get("won", 0)), 1, "Won games should be 1")
	assert_eq(int(stats_win.get("current_streak", 0)), 1, "Current streak should be 1")
	assert_eq(int(stats_win.get("max_streak", 0)), 1, "Max streak should be 1")
	assert_eq(int(stats_win.get("distribution", {}).get("3", 0)), 1, "Distribution for 3 attempts should be 1")
	assert_eq(stats_mgr.get_win_percentage(GameManagerScript.GameMode.CONTINUOUS), 100, "Win % should be 100")
	
	# Record Loss
	stats_mgr.record_game(GameManagerScript.GameMode.CONTINUOUS, false, 0, 0.0, TEST_STATS_PATH)
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
	stats_mgr.record_game(GameManagerScript.GameMode.DAILY, true, 4, 0.0, TEST_STATS_PATH)
	
	var daily_stats: Dictionary = stats_mgr.get_stats_for_mode(GameManagerScript.GameMode.DAILY)
	var cont_stats: Dictionary = stats_mgr.get_stats_for_mode(GameManagerScript.GameMode.CONTINUOUS)
	
	assert_eq(int(daily_stats.get("played", 0)), 1, "Daily played should be 1")
	assert_eq(int(cont_stats.get("played", 0)), 0, "Continuous played should remain 0")

func test_stats_screen_ui() -> void:
	var scn: PackedScene = load("res://scenes/stats_screen.tscn") as PackedScene
	assert_true(scn != null, "stats_screen.tscn should load")
	
	var screen: Node = scn.instantiate()
	assert_true(screen != null, "stats_screen should instantiate")
	
	var mode_tabs: TabContainer = screen.find_child("ModeTabs", true, false) as TabContainer
	assert_true(mode_tabs != null, "ModeTabs TabContainer should exist in StatsScreen")
	assert_eq(mode_tabs.get_tab_count(), 2, "ModeTabs should contain 2 tabs")
	assert_eq(mode_tabs.get_tab_title(0), "Continuous Play", "Tab 0 should be Continuous Play")
	assert_eq(mode_tabs.get_tab_title(1), "Daily Challenge", "Tab 1 should be Daily Challenge")
	
	# Verify StyleBox borders for active and inactive tabs
	var selected_style: StyleBoxFlat = mode_tabs.get_theme_stylebox("tab_selected") as StyleBoxFlat
	assert_true(selected_style != null, "tab_selected stylebox should exist")
	assert_eq(selected_style.border_width_bottom, 0, "Selected tab should have no bottom border to merge with panel")
	
	var unselected_style: StyleBoxFlat = mode_tabs.get_theme_stylebox("tab_unselected") as StyleBoxFlat
	assert_true(unselected_style != null, "tab_unselected stylebox should exist")
	assert_true(unselected_style.border_width_bottom > 0, "Unselected tab should have a bottom border separating it from panel")
	
	# Programmatic mode switching via set_mode
	screen.call("set_mode", GameManagerScript.GameMode.DAILY)
	assert_eq(int(screen.get("active_mode")), GameManagerScript.GameMode.DAILY, "active_mode should be DAILY")
	
	var dist_box: Node = screen.find_child("DistributionContainer", true, false)
	assert_true(dist_box != null, "DistributionContainer should exist in StatsScreen")
	assert_eq(dist_box.get_child_count(), 7, "DistributionContainer should render 7 rows (1..6 + loss)")
	
	screen.call("set_mode", GameManagerScript.GameMode.CONTINUOUS)
	assert_eq(int(screen.get("active_mode")), GameManagerScript.GameMode.CONTINUOUS, "active_mode should be CONTINUOUS")
	
	# Typography & Layout Sizing assertions
	var title = screen.find_child("Title", true, false)
	if title:
		assert_eq(title.get_theme_font_size("font_size"), 52, "Title font size should be 52")
		
	var close_btn = screen.find_child("CloseButton", true, false)
	if close_btn:
		assert_eq(close_btn.get_theme_font_size("font_size"), 32, "Close button font size should be 32")
		assert_true(close_btn.custom_minimum_size.x >= 50 and close_btn.custom_minimum_size.y >= 50, "Close button min size should be >= 50x50")
		
	if mode_tabs:
		assert_eq(mode_tabs.get_theme_font_size("font_size"), 32, "ModeTabs font size should be 32")
		
	var played_card = screen.find_child("PlayedCard", true, false)
	if played_card:
		var p_val = played_card.get_node("Value")
		var p_lbl = played_card.get_node("Label")
		assert_true(p_val.get_theme_font_size("font_size") >= 36, "Summary card value font size should be >= 36")
		assert_true(p_lbl.get_theme_font_size("font_size") >= 18, "Summary card description font size should be >= 18")
		
	var summary_cards = screen.find_child("SummaryCards", true, false)
	if summary_cards:
		assert_eq(summary_cards.get_child_count(), 6, "SummaryCards should have 6 children")
		assert_eq(summary_cards.get_child(0).name, "PlayedCard", "Index 0 should be PlayedCard")
		assert_eq(summary_cards.get_child(1).name, "MaxStreakCard", "Index 1 should be MaxStreakCard")
		assert_eq(summary_cards.get_child(2).name, "BestTimeCard", "Index 2 should be BestTimeCard")
		assert_eq(summary_cards.get_child(3).name, "WinPctCard", "Index 3 should be WinPctCard")
		assert_eq(summary_cards.get_child(4).name, "StreakCard", "Index 4 should be StreakCard")
		assert_eq(summary_cards.get_child(5).name, "AvgTimeCard", "Index 5 should be AvgTimeCard")
		
	if dist_box and dist_box.get_child_count() > 0:
		var row_hbox = dist_box.get_child(0)
		assert_true(row_hbox.custom_minimum_size.y >= 40, "Distribution row minimum height should be >= 40")
		var count_lbl = row_hbox.get_child(1).get_child(0)
		assert_true(count_lbl.get_theme_font_size("font_size") >= 20, "Distribution bar text font size should be >= 20")
	
	# Verify tab changed handler responds to user tab switches
	screen.call("_on_tab_changed", 1)
	assert_eq(int(screen.get("active_mode")), GameManagerScript.GameMode.DAILY, "active_mode should update to DAILY on tab changed")
	
	screen.call("_on_tab_changed", 0)
	assert_eq(int(screen.get("active_mode")), GameManagerScript.GameMode.CONTINUOUS, "active_mode should update to CONTINUOUS on tab changed")
	
	screen.free()

func test_time_stats() -> void:
	stats_mgr.reset_all_stats(TEST_STATS_PATH)
	stats_mgr.record_game(GameManagerScript.GameMode.CONTINUOUS, true, 3, 100.0, TEST_STATS_PATH)
	assert_eq(stats_mgr.get_best_time(GameManagerScript.GameMode.CONTINUOUS), 100.0, "Best time should be 100")
	assert_eq(stats_mgr.get_average_time(GameManagerScript.GameMode.CONTINUOUS), 100.0, "Avg time should be 100")
	stats_mgr.record_game(GameManagerScript.GameMode.CONTINUOUS, true, 4, 50.0, TEST_STATS_PATH)
	assert_eq(stats_mgr.get_best_time(GameManagerScript.GameMode.CONTINUOUS), 50.0, "Best time should update to 50")
	assert_eq(stats_mgr.get_average_time(GameManagerScript.GameMode.CONTINUOUS), 75.0, "Avg time should be 75")
	stats_mgr.record_game(GameManagerScript.GameMode.CONTINUOUS, false, 0, 300.0, TEST_STATS_PATH)
	assert_eq(stats_mgr.get_best_time(GameManagerScript.GameMode.CONTINUOUS), 50.0, "Best time should remain 50")
	assert_eq(stats_mgr.get_average_time(GameManagerScript.GameMode.CONTINUOUS), 75.0, "Avg time should remain 75")

func test_stats_loading_types() -> void:
	stats_mgr.reset_all_stats(TEST_STATS_PATH)
	
	# Manually write a mock JSON with float values
	var mock_data: Dictionary = {
		"continuous": {
			"played": 5.0,
			"won": 3.0,
			"current_streak": 1.0,
			"max_streak": 2.0,
			"best_time": 45.5,
			"total_won_time": 150.0,
			"distribution": { "1": 0.0, "2": 1.0, "3": 1.0, "4": 1.0, "5": 0.0, "6": 0.0, "loss": 2.0 }
		},
		"daily": {
			"played": 1.0, "won": 1.0, "current_streak": 1.0, "max_streak": 1.0,
			"best_time": 60.0, "total_won_time": 60.0,
			"distribution": { "1": 0.0, "2": 0.0, "3": 0.0, "4": 1.0, "5": 0.0, "6": 0.0, "loss": 0.0 }
		}
	}
	var file: FileAccess = FileAccess.open(TEST_STATS_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(mock_data))
	file.close()
	
	stats_mgr.load_stats(TEST_STATS_PATH)
	var stats_cont: Dictionary = stats_mgr.get_stats_for_mode(GameManagerScript.GameMode.CONTINUOUS)
	
	assert_true(typeof(stats_cont["played"]) == TYPE_INT, "played should be cast to int")
	assert_true(typeof(stats_cont["won"]) == TYPE_INT, "won should be cast to int")
	assert_true(typeof(stats_cont["current_streak"]) == TYPE_INT, "current_streak should be cast to int")
	assert_true(typeof(stats_cont["max_streak"]) == TYPE_INT, "max_streak should be cast to int")
	assert_true(typeof(stats_cont["best_time"]) == TYPE_FLOAT, "best_time should remain float")
	
	var dist: Dictionary = stats_cont.get("distribution", {}) as Dictionary
	assert_true(typeof(dist["2"]) == TYPE_INT, "distribution counts should be cast to int")

func test_stats_screen_integer_formatting() -> void:
	var scn: PackedScene = load("res://scenes/stats_screen.tscn") as PackedScene
	var screen: Node = scn.instantiate()
	
	# Mock StatsManager with float values
	var mock_sm = Node.new()
	var mock_script = GDScript.new()
	mock_script.source_code = """
extends Node
func get_stats_for_mode(mode: int) -> Dictionary:
	return { "played": 5.0, "won": 3.0, "current_streak": 2.0, "max_streak": 3.0, "distribution": {} }
func get_win_percentage(mode: int) -> int:
	return 60
func get_best_time(mode: int) -> float:
	return 45.0
func get_average_time(mode: int) -> float:
	return 50.0
"""
	mock_script.reload()
	mock_sm.set_script(mock_script)
	
	screen.call("set_stats_manager", mock_sm)
	
	# Check Continuous Play
	screen.call("set_mode", GameManagerScript.GameMode.CONTINUOUS)
	screen.call("refresh_display")
	
	var played_val = screen.get("played_val")
	var streak_val = screen.get("streak_val")
	var max_streak_val = screen.get("max_streak_val")
	
	assert_true(not played_val.text.contains("."), "Played should not contain decimal point")
	assert_true(not streak_val.text.contains("."), "Current Streak should not contain decimal point")
	assert_true(not max_streak_val.text.contains("."), "Max Streak should not contain decimal point")
	
	assert_eq(played_val.text, "5", "Played should be formatted as integer 5")
	assert_eq(streak_val.text, "2", "Streak should be formatted as integer 2")
	assert_eq(max_streak_val.text, "3", "Max Streak should be formatted as integer 3")
	
	# Check Daily Challenge
	screen.call("set_mode", GameManagerScript.GameMode.DAILY)
	screen.call("refresh_display")
	
	assert_true(not played_val.text.contains("."), "Played should not contain decimal point in Daily Challenge")
	assert_eq(played_val.text, "5", "Played should be formatted as integer 5 in Daily Challenge")
	
	mock_sm.free()
	screen.free()
