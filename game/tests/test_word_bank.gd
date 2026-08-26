# tests/test_word_bank.gd
extends "res://tests/test_base.gd"

## Automated unit tests for WordBank AutoLoad.

const WordBankScript = preload("res://autoloads/word_bank.gd")

var word_bank: Node = null

func _init() -> void:
	word_bank = WordBankScript.new()
	word_bank.load_words("res://assets/words/words.txt")

func cleanup() -> void:
	if word_bank != null and is_instance_valid(word_bank):
		word_bank.free()
		word_bank = null

func test_word_bank_loads_successfully() -> void:
	assert_true(word_bank.is_loaded(), "WordBank should report loaded status")
	assert_true(word_bank.get_word_count() > 1000, "WordBank should have at least 1,000 words loaded")

func test_has_duplicate_letters() -> void:
	assert_true(word_bank.has_duplicate_letters("APPLE"), "APPLE has duplicate P's")
	assert_true(word_bank.has_duplicate_letters("SHEEP"), "SHEEP has duplicate E's")
	assert_true(word_bank.has_duplicate_letters("LLAMA"), "LLAMA has duplicate L's and A's")
	assert_true(word_bank.has_duplicate_letters("TESTS"), "TESTS has duplicate T's and S's")
	
	assert_false(word_bank.has_duplicate_letters("LOGIC"), "LOGIC has all unique letters")
	assert_false(word_bank.has_duplicate_letters("PLANT"), "PLANT has all unique letters")
	assert_false(word_bank.has_duplicate_letters("BRICK"), "BRICK has all unique letters")
	assert_false(word_bank.has_duplicate_letters("CLIMB"), "CLIMB has all unique letters")

func test_is_valid_word() -> void:
	# Words with duplicate letters must be invalid even if 5 letters
	assert_false(word_bank.is_valid_word("APPLE"), "APPLE has duplicate letters, must be invalid")
	assert_false(word_bank.is_valid_word("GEESE"), "GEESE has duplicate letters, must be invalid")
	
	# Words with invalid lengths must be invalid
	assert_false(word_bank.is_valid_word("FOUR"), "4-letter word must be invalid")
	assert_false(word_bank.is_valid_word("SIXLET"), "6-letter word must be invalid")
	
	# Nonsense words must be invalid
	assert_false(word_bank.is_valid_word("XZQJK"), "Random letters should not be valid")
	
	# Real 5-letter isograms should be valid
	assert_true(word_bank.is_valid_word("LOGIC"), "LOGIC should be a valid word")
	assert_true(word_bank.is_valid_word("PLANT"), "PLANT should be a valid word")
	assert_true(word_bank.is_valid_word("BRICK"), "BRICK should be a valid word")

func test_all_sample_words_are_isograms() -> void:
	# Test 500 deterministic picks to ensure none contain duplicate letters
	for i in range(500):
		var word: String = word_bank.get_random_word(i * 13 + 7)
		assert_eq(word.length(), 5, "Word length must be exactly 5")
		assert_false(word_bank.has_duplicate_letters(word), "Word '%s' must not have duplicate letters" % word)

func test_seeded_random_word_consistency() -> void:
	var seed_val: int = 20260826
	var word1: String = word_bank.get_random_word(seed_val)
	var word2: String = word_bank.get_random_word(seed_val)
	
	assert_eq(word1, word2, "Seeded random word generation must be deterministic for Daily Challenge")
	assert_true(word_bank.is_valid_word(word1), "Seeded word must be a valid word")
