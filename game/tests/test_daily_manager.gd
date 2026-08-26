# tests/test_daily_manager.gd
extends "res://tests/test_base.gd"

## Automated unit tests for DailyManager AutoLoad.

const DailyManagerScript = preload("res://autoloads/daily_manager.gd")
const WordBankScript = preload("res://autoloads/word_bank.gd")

const TEST_RECORDS_PATH: String = "user://test_daily_records.json"

var daily_mgr: Node = null
var word_bank: Node = null

func _init() -> void:
	word_bank = WordBankScript.new()
	word_bank.load_words("res://assets/words/words.txt")
	daily_mgr = DailyManagerScript.new()
	daily_mgr.set_word_bank(word_bank)

func cleanup() -> void:
	if daily_mgr != null and is_instance_valid(daily_mgr):
		daily_mgr.clear_records(TEST_RECORDS_PATH)
		daily_mgr.free()
		daily_mgr = null
	if word_bank != null and is_instance_valid(word_bank):
		word_bank.free()
		word_bank = null

func test_utc_date_string_format() -> void:
	var date_str: String = daily_mgr.get_current_utc_date_string()
	assert_eq(date_str.length(), 10, "UTC date string should be 10 characters (YYYY-MM-DD)")
	assert_eq(date_str[4], "-", "Character at index 4 must be '-'")
	assert_eq(date_str[7], "-", "Character at index 7 must be '-'")

func test_deterministic_seed_generation() -> void:
	var seed_1: int = daily_mgr.get_date_seed("2026-08-26")
	var seed_2: int = daily_mgr.get_date_seed("2026-08-26")
	var seed_3: int = daily_mgr.get_date_seed("2026-08-27")
	
	assert_eq(seed_1, seed_2, "Same date string must produce identical seed")
	assert_ne(seed_1, seed_3, "Different date strings should produce different seeds")

func test_daily_word_consistency() -> void:
	var word_a: String = daily_mgr.get_daily_word("2026-08-26")
	var word_b: String = daily_mgr.get_daily_word("2026-08-26")
	
	assert_eq(word_a, word_b, "Daily word for the same date must be 100% consistent")
	assert_eq(word_a.length(), 5, "Daily word must have 5 letters")
	assert_true(word_bank.is_valid_word(word_a), "Daily word must be a valid isogram in WordBank")

func test_seconds_until_next_utc_midnight() -> void:
	var seconds_left: int = daily_mgr.get_seconds_until_next_utc_midnight()
	assert_true(seconds_left >= 0, "Remaining seconds must be non-negative")
	assert_true(seconds_left <= 86400, "Remaining seconds must be <= 86400")
	
	var formatted_countdown: String = daily_mgr.get_formatted_countdown_to_next_utc()
	assert_eq(formatted_countdown.length(), 8, "Formatted countdown must be HH:MM:SS (8 chars)")
	assert_eq(formatted_countdown[2], ":", "Separator at index 2 should be ':'")
	assert_eq(formatted_countdown[5], ":", "Separator at index 5 should be ':'")

func test_daily_completion_and_lockout() -> void:
	var test_date: String = "2026-08-26"
	assert_false(daily_mgr.is_daily_completed(test_date), "Should not be completed initially")
	
	daily_mgr.mark_daily_completed(test_date, true, 4, TEST_RECORDS_PATH)
	assert_true(daily_mgr.is_daily_completed(test_date), "Should be marked completed after recording")
	
	var info: Dictionary = daily_mgr.get_daily_completion_info(test_date)
	assert_eq(info.get("date", ""), test_date, "Recorded date must match")
	assert_eq(bool(info.get("won", false)), true, "Recorded win status must match")
	assert_eq(int(info.get("attempts", 0)), 4, "Recorded attempts must match")
