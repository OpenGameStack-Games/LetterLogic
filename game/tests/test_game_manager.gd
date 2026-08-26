# tests/test_game_manager.gd
extends "res://tests/test_base.gd"

## Automated unit tests for GameManager AutoLoad.

const GameManagerScript = preload("res://autoloads/game_manager.gd")
const WordBankScript = preload("res://autoloads/word_bank.gd")

var game_mgr: Node = null
var word_bank: Node = null

func _init() -> void:
	word_bank = WordBankScript.new()
	word_bank.load_words("res://assets/words/words.txt")
	game_mgr = GameManagerScript.new()
	game_mgr.set_word_bank(word_bank)

func cleanup() -> void:
	if game_mgr != null and is_instance_valid(game_mgr):
		game_mgr.free()
		game_mgr = null
	if word_bank != null and is_instance_valid(word_bank):
		word_bank.free()
		word_bank = null

func test_game_initialization() -> void:
	game_mgr.start_game(GameManagerScript.GameMode.CONTINUOUS, "LOGIC")
	assert_eq(game_mgr.secret_word, "LOGIC", "Secret word must be LOGIC")
	assert_eq(game_mgr.current_row, 0, "Initial row should be 0")
	assert_eq(game_mgr.current_guess, "", "Initial guess string should be empty")
	assert_eq(game_mgr.game_status, GameManagerScript.GameStatus.IN_PROGRESS, "Game should be in progress")

func test_add_and_remove_letters() -> void:
	game_mgr.start_game(GameManagerScript.GameMode.CONTINUOUS, "LOGIC")
	
	assert_true(game_mgr.add_letter("L"), "Adding 'L' should succeed")
	assert_true(game_mgr.add_letter("O"), "Adding 'O' should succeed")
	assert_true(game_mgr.add_letter("G"), "Adding 'G' should succeed")
	assert_eq(game_mgr.current_guess, "LOG", "Current guess should be LOG")
	
	# Test removing letter
	assert_true(game_mgr.remove_letter(), "Removing letter should succeed")
	assert_eq(game_mgr.current_guess, "LO", "Current guess should be LO after backspace")
	
	# Test filling to 5 letters
	assert_true(game_mgr.add_letter("G"), "Adding 'G' again should succeed")
	assert_true(game_mgr.add_letter("I"), "Adding 'I' should succeed")
	assert_true(game_mgr.add_letter("C"), "Adding 'C' should succeed")
	assert_eq(game_mgr.current_guess, "LOGIC", "Current guess should be full LOGIC")
	
	# 6th letter should fail
	assert_false(game_mgr.add_letter("S"), "Adding 6th letter should fail")
	assert_eq(game_mgr.current_guess, "LOGIC", "Guess length should remain 5")

func test_prevent_duplicate_letters_in_current_row() -> void:
	game_mgr.start_game(GameManagerScript.GameMode.CONTINUOUS, "LOGIC")
	
	assert_true(game_mgr.add_letter("A"), "Adding 'A' should succeed")
	assert_true(game_mgr.add_letter("B"), "Adding 'B' should succeed")
	assert_false(game_mgr.add_letter("A"), "Adding duplicate 'A' in same row must fail")
	assert_false(game_mgr.add_letter("B"), "Adding duplicate 'B' in same row must fail")
	assert_eq(game_mgr.current_guess, "AB", "Guess must remain AB without duplicates")
	
	# After removing B, B can be added again
	assert_true(game_mgr.remove_letter(), "Removing 'B' should succeed")
	assert_true(game_mgr.add_letter("B"), "Adding 'B' back should succeed")

func test_evaluate_guess() -> void:
	# Secret: PLANT
	# Guess: POINT -> P (CORRECT), O (ABSENT), I (ABSENT), N (CORRECT), T (CORRECT)
	var results: Array = game_mgr.evaluate_guess("POINT", "PLANT")
	assert_eq(results[0], GameManagerScript.TileState.CORRECT, "P should be CORRECT")
	assert_eq(results[1], GameManagerScript.TileState.ABSENT, "O should be ABSENT")
	assert_eq(results[2], GameManagerScript.TileState.ABSENT, "I should be ABSENT")
	assert_eq(results[3], GameManagerScript.TileState.CORRECT, "N should be CORRECT")
	assert_eq(results[4], GameManagerScript.TileState.CORRECT, "T should be CORRECT")
	
	# Secret: PLANT
	# Guess: TRAIN -> T (PRESENT), R (ABSENT), A (CORRECT), I (ABSENT), N (PRESENT)
	results = game_mgr.evaluate_guess("TRAIN", "PLANT")
	assert_eq(results[0], GameManagerScript.TileState.PRESENT, "T should be PRESENT")
	assert_eq(results[1], GameManagerScript.TileState.ABSENT, "R should be ABSENT")
	assert_eq(results[2], GameManagerScript.TileState.CORRECT, "A should be CORRECT")
	assert_eq(results[3], GameManagerScript.TileState.ABSENT, "I should be ABSENT")
	assert_eq(results[4], GameManagerScript.TileState.PRESENT, "N should be PRESENT")

func test_win_condition() -> void:
	game_mgr.start_game(GameManagerScript.GameMode.CONTINUOUS, "LOGIC")
	for char in "LOGIC":
		game_mgr.add_letter(char)
	
	var sub_res: Dictionary = game_mgr.submit_guess()
	assert_true(sub_res.success, "Submitting valid guess should succeed")
	assert_eq(game_mgr.game_status, GameManagerScript.GameStatus.WON, "Game status should transition to WON")
	assert_eq(game_mgr.current_row, 1, "Current row should be 1 after 1 guess")

func test_loss_condition() -> void:
	game_mgr.start_game(GameManagerScript.GameMode.CONTINUOUS, "LOGIC")
	
	var guesses_to_make: Array[String] = ["PLANT", "BRICK", "SHOUT", "FUDGE", "ZEBRA", "VIXEN"]
	for guess_word in guesses_to_make:
		for char in guess_word:
			game_mgr.add_letter(char)
		var res: Dictionary = game_mgr.submit_guess()
		assert_true(res.success, "Guess '%s' should submit successfully" % guess_word)
	
	assert_eq(game_mgr.current_row, 6, "All 6 rows should be exhausted")
	assert_eq(game_mgr.game_status, GameManagerScript.GameStatus.LOST, "Game status should be LOST after 6 failed guesses")
