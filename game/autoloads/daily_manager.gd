# autoloads/daily_manager.gd
extends Node

## DailyManager AutoLoad
## Manages the synchronized global Daily Challenge for LetterLogic.
## Calculates UTC date strings, deterministic daily seeds, countdown timers, and daily lockout records.

const WordBankScript = preload("res://autoloads/word_bank.gd")
const SaveManagerScript = preload("res://autoloads/save_manager.gd")

const DAILY_RECORDS_PATH: String = "user://daily_records.json"

var _word_bank_ref: Node = null
var _daily_records: Dictionary = {}

func _ready() -> void:
	load_records()

func set_word_bank(wb: Node) -> void:
	_word_bank_ref = wb

func get_word_bank() -> Node:
	if _word_bank_ref != null and is_instance_valid(_word_bank_ref):
		return _word_bank_ref
	if is_inside_tree() and get_node_or_null("/root/WordBank") != null:
		_word_bank_ref = get_node("/root/WordBank")
	return _word_bank_ref

## Returns the current date formatted as 'YYYY-MM-DD' in UTC timezone.
func get_current_utc_date_string() -> String:
	var dt: Dictionary = Time.get_datetime_dict_from_system(true)
	return "%04d-%02d-%02d" % [int(dt.year), int(dt.month), int(dt.day)]

## Computes a deterministic integer seed from a date string (e.g. '2026-08-26').
func get_date_seed(date_str: String = "") -> int:
	var target_date: String = date_str if date_str != "" else get_current_utc_date_string()
	var hash_val: int = 5381
	for i in range(target_date.length()):
		var c: int = target_date.unicode_at(i)
		hash_val = ((hash_val << 5) + hash_val) + c
	return abs(hash_val)

## Returns the synchronized 5-letter isogram for the specified UTC date.
func get_daily_word(date_str: String = "") -> String:
	var target_date: String = date_str if date_str != "" else get_current_utc_date_string()
	var seed_val: int = get_date_seed(target_date)
	var wb: Node = get_word_bank()
	if wb != null and wb.has_method("get_random_word"):
		return wb.get_random_word(seed_val)
	return "LOGIC"

## Returns seconds remaining until the next UTC midnight (00:00:00 UTC).
func get_seconds_until_next_utc_midnight() -> int:
	var dt: Dictionary = Time.get_datetime_dict_from_system(true)
	var current_seconds: int = int(dt.hour) * 3600 + int(dt.minute) * 60 + int(dt.second)
	var seconds_in_day: int = 86400
	var remaining: int = seconds_in_day - current_seconds
	return clampi(remaining, 0, seconds_in_day)

## Formats remaining time until next UTC midnight as 'HH:MM:SS'.
func get_formatted_countdown_to_next_utc() -> String:
	var remaining_sec: int = get_seconds_until_next_utc_midnight()
	var hours: int = remaining_sec / 3600
	var minutes: int = (remaining_sec % 3600) / 60
	var seconds: int = remaining_sec % 60
	return "%02d:%02d:%02d" % [hours, minutes, seconds]

## Checks whether the player has already finished the Daily Challenge for the given date.
func is_daily_completed(date_str: String = "") -> bool:
	var target_date: String = date_str if date_str != "" else get_current_utc_date_string()
	return _daily_records.has(target_date)

## Returns completion details for a date (or empty dictionary if uncompleted).
func get_daily_completion_info(date_str: String = "") -> Dictionary:
	var target_date: String = date_str if date_str != "" else get_current_utc_date_string()
	if _daily_records.has(target_date):
		return _daily_records[target_date]
	return {}

## Marks a specific Daily Challenge as completed and saves to disk.
func mark_daily_completed(date_str: String, won: bool, attempts: int, custom_path: String = "") -> bool:
	var target_date: String = date_str if date_str != "" else get_current_utc_date_string()
	_daily_records[target_date] = {
		"date": target_date,
		"won": won,
		"attempts": attempts,
		"timestamp": Time.get_unix_time_from_system()
	}
	return save_records(custom_path)

## Loads daily completion records from disk.
func load_records(custom_path: String = "") -> void:
	var path: String = custom_path if custom_path != "" else DAILY_RECORDS_PATH
	if not FileAccess.file_exists(path):
		_daily_records = {}
		return
	
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		_daily_records = {}
		return
	
	var text: String = file.get_as_text()
	file.close()
	
	var json: JSON = JSON.new()
	if json.parse(text) == OK and json.data is Dictionary:
		_daily_records = json.data as Dictionary
	else:
		_daily_records = {}

## Saves daily completion records to disk.
func save_records(custom_path: String = "") -> bool:
	var path: String = custom_path if custom_path != "" else DAILY_RECORDS_PATH
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("DailyManager: Failed to write daily records to '%s'" % path)
		return false
	file.store_string(JSON.stringify(_daily_records, "\t"))
	file.close()
	return true

## Clears records (mainly for testing/reset).
func clear_records(custom_path: String = "") -> void:
	_daily_records.clear()
	var path: String = custom_path if custom_path != "" else DAILY_RECORDS_PATH
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
