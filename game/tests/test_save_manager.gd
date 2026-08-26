# tests/test_save_manager.gd
extends "res://tests/test_base.gd"

## Automated unit tests for SaveManager AutoLoad.

const SaveManagerScript = preload("res://autoloads/save_manager.gd")
const GameManagerScript = preload("res://autoloads/game_manager.gd")
const WordBankScript = preload("res://autoloads/word_bank.gd")

const TEST_SAVE_DAILY: String = "user://test_save_daily.json"
const TEST_SAVE_CONTINUOUS: String = "user://test_save_continuous.json"

var save_mgr: Node = null
var word_bank: Node = null

func _init() -> void:
	save_mgr = SaveManagerScript.new()
	word_bank = WordBankScript.new()
	word_bank.load_words("res://assets/words/words.txt")

func cleanup() -> void:
	if save_mgr != null and is_instance_valid(save_mgr):
		save_mgr.clear_game_state(GameManagerScript.GameMode.DAILY, TEST_SAVE_DAILY)
		save_mgr.clear_game_state(GameManagerScript.GameMode.CONTINUOUS, TEST_SAVE_CONTINUOUS)
		save_mgr.free()
		save_mgr = null
	if word_bank != null and is_instance_valid(word_bank):
		word_bank.free()
		word_bank = null

func test_save_and_load_game_state() -> void:
	var dummy_data: Dictionary = {
		"secret_word": "PLANT",
		"current_row": 2,
		"current_guess": "BR",
		"guesses": ["LOGIC", "SHOUT"]
	}
	
	var save_ok: bool = save_mgr.save_game_state(GameManagerScript.GameMode.DAILY, dummy_data, TEST_SAVE_DAILY)
	assert_true(save_ok, "Saving game state should return true")
	assert_true(save_mgr.has_saved_game(GameManagerScript.GameMode.DAILY, TEST_SAVE_DAILY), "has_saved_game should return true")
	
	var loaded_data: Dictionary = save_mgr.load_game_state(GameManagerScript.GameMode.DAILY, TEST_SAVE_DAILY)
	assert_eq(loaded_data.get("secret_word", ""), "PLANT", "Loaded secret word must match")
	assert_eq(int(loaded_data.get("current_row", 0)), 2, "Loaded current row must match")
	assert_eq(loaded_data.get("current_guess", ""), "BR", "Loaded current guess must match")
	
	var loaded_guesses: Array = loaded_data.get("guesses", [])
	assert_eq(loaded_guesses.size(), 2, "Guesses size should be 2")
	assert_eq(loaded_guesses[0], "LOGIC", "First guess should be LOGIC")

func test_mode_isolation() -> void:
	var daily_data: Dictionary = { "secret_word": "DAILY" }
	var cont_data: Dictionary = { "secret_word": "CONTS" }
	
	save_mgr.save_game_state(GameManagerScript.GameMode.DAILY, daily_data, TEST_SAVE_DAILY)
	save_mgr.save_game_state(GameManagerScript.GameMode.CONTINUOUS, cont_data, TEST_SAVE_CONTINUOUS)
	
	var loaded_daily: Dictionary = save_mgr.load_game_state(GameManagerScript.GameMode.DAILY, TEST_SAVE_DAILY)
	var loaded_cont: Dictionary = save_mgr.load_game_state(GameManagerScript.GameMode.CONTINUOUS, TEST_SAVE_CONTINUOUS)
	
	assert_eq(loaded_daily.get("secret_word", ""), "DAILY", "Daily save must be isolated")
	assert_eq(loaded_cont.get("secret_word", ""), "CONTS", "Continuous save must be isolated")

func test_clear_game_state() -> void:
	save_mgr.save_game_state(GameManagerScript.GameMode.DAILY, { "test": 1 }, TEST_SAVE_DAILY)
	assert_true(save_mgr.has_saved_game(GameManagerScript.GameMode.DAILY, TEST_SAVE_DAILY), "File should exist before clear")
	
	save_mgr.clear_game_state(GameManagerScript.GameMode.DAILY, TEST_SAVE_DAILY)
	assert_false(save_mgr.has_saved_game(GameManagerScript.GameMode.DAILY, TEST_SAVE_DAILY), "File should not exist after clear")

func test_corrupted_json_handling() -> void:
	var f: FileAccess = FileAccess.open(TEST_SAVE_DAILY, FileAccess.WRITE)
	f.store_string("{ INVALID JSON CORRUPTED ...")
	f.close()
	
	var loaded: Dictionary = save_mgr.load_game_state(GameManagerScript.GameMode.DAILY, TEST_SAVE_DAILY)
	assert_true(loaded.is_empty(), "Corrupted JSON should load as empty Dictionary without crashing")
	assert_false(save_mgr.has_saved_game(GameManagerScript.GameMode.DAILY, TEST_SAVE_DAILY), "Corrupted save file should be cleared automatically")

func test_game_manager_roundtrip() -> void:
	var gm_src: Node = GameManagerScript.new()
	gm_src.set_word_bank(word_bank)
	gm_src.start_game(GameManagerScript.GameMode.CONTINUOUS, "LOGIC")
	
	# Submit a guess
	for c in "PLANT":
		gm_src.add_letter(c)
	gm_src.submit_guess()
	
	# Type partial next guess
	gm_src.add_letter("B")
	gm_src.add_letter("R")
	
	# Serialize
	var serialized: Dictionary = save_mgr.serialize_game_manager(gm_src)
	
	# Deserialize into fresh GameManager
	var gm_dst: Node = GameManagerScript.new()
	gm_dst.set_word_bank(word_bank)
	var restore_ok: bool = save_mgr.deserialize_to_game_manager(serialized, gm_dst)
	
	assert_true(restore_ok, "Deserialization should return true")
	assert_eq(gm_dst.secret_word, "LOGIC", "Secret word must match")
	assert_eq(gm_dst.current_row, 1, "Current row must be 1")
	assert_eq(gm_dst.current_guess, "BR", "Current partial guess must be BR")
	assert_eq(gm_dst.guesses.size(), 1, "Guesses size must be 1")
	assert_eq(gm_dst.guesses[0], "PLANT", "First guess must be PLANT")
	assert_eq(gm_dst.keyboard_states.get("L", -1), GameManagerScript.TileState.PRESENT, "Key L should be marked PRESENT")
	
	gm_src.free()
	gm_dst.free()
