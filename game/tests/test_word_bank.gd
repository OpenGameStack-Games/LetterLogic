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
	assert_eq(word_bank.get_word_count(), 1581, "WordBank should have exactly 1,581 words loaded")

func test_startup_word_bank_is_loaded_with_words() -> void:
	assert_true(word_bank.is_loaded() == true, "WordBank should be loaded during startup initialization")
	assert_true(word_bank.get_word_count() > 0, "WordBank startup initialization must load a non-empty dictionary")

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

	# Simple plurals ending in S should be invalid
	assert_false(word_bank.is_valid_word("BIRDS"), "BIRDS is a simple plural, should be invalid")
	assert_false(word_bank.is_valid_word("CARTS"), "CARTS is a simple plural, should be invalid")
	
	# Past-tense verbs ending in ED should be invalid
	assert_false(word_bank.is_valid_word("ACTED"), "ACTED is a past-tense verb, should be invalid")
	assert_false(word_bank.is_valid_word("HIKED"), "HIKED is a past-tense verb, should be invalid")
	
	# Obscure words should be rejected
	assert_false(word_bank.is_valid_word("RIOJA"), "RIOJA is an obscure word, should be invalid")

	# True singulars ending in S should be valid
	assert_true(word_bank.is_valid_word("CHAOS"), "CHAOS is a valid singular noun")
	assert_true(word_bank.is_valid_word("FOCUS"), "FOCUS is a valid singular noun")
	assert_true(word_bank.is_valid_word("VIRUS"), "VIRUS is a valid singular noun")

	# Common vocabulary words from official Wordle isogram solution list should be valid
	assert_true(word_bank.is_valid_word("NICHE"), "NICHE should be a valid word")
	assert_true(word_bank.is_valid_word("RABID"), "RABID should be a valid word")
	assert_true(word_bank.is_valid_word("UNLIT"), "UNLIT should be a valid word")
	assert_true(word_bank.is_valid_word("ABOUT"), "ABOUT should be a valid word")
	assert_true(word_bank.is_valid_word("AFTER"), "AFTER should be a valid word")
	assert_true(word_bank.is_valid_word("UNDER"), "UNDER should be a valid word")

	# Expanded common isograms should be valid
	assert_true(word_bank.is_valid_word("PSYCH"), "PSYCH should be a valid word")
	assert_true(word_bank.is_valid_word("LASER"), "LASER should be a valid word")
	assert_true(word_bank.is_valid_word("SQUID"), "SQUID should be a valid word")
	assert_true(word_bank.is_valid_word("LITER"), "LITER should be a valid word")
	assert_true(word_bank.is_valid_word("MIXER"), "MIXER should be a valid word")
	assert_true(word_bank.is_valid_word("SAVER"), "SAVER should be a valid word")
	assert_true(word_bank.is_valid_word("TONER"), "TONER should be a valid word")
	assert_true(word_bank.is_valid_word("TUNER"), "TUNER should be a valid word")
	assert_true(word_bank.is_valid_word("BIKER"), "BIKER should be a valid word")
	assert_true(word_bank.is_valid_word("WIPER"), "WIPER should be a valid word")
	assert_true(word_bank.is_valid_word("MISTY"), "MISTY should be a valid word")
	assert_true(word_bank.is_valid_word("LATEX"), "LATEX should be a valid word")
	assert_true(word_bank.is_valid_word("REMIX"), "REMIX should be a valid word")
	assert_true(word_bank.is_valid_word("SABER"), "SABER should be a valid word")
	assert_true(word_bank.is_valid_word("OCHER"), "OCHER should be a valid word")

func test_android_reference_words_are_valid() -> void:
	assert_true(word_bank.is_valid_word("ADORE"), "ADORE must be valid after Android word bank load")
	assert_true(word_bank.is_valid_word("THANK"), "THANK must be valid after Android word bank load")

func test_android_export_includes_plain_text_word_list() -> void:
	var config: ConfigFile = ConfigFile.new()
	var err: Error = config.load("res://export_presets.cfg")
	assert_eq(err, OK, "export_presets.cfg should load for Android export verification")
	if err == OK:
		var export_filter: String = String(config.get_value("preset.0", "export_filter", ""))
		var include_filter: String = String(config.get_value("preset.0", "include_filter", ""))
		var include_patterns: PackedStringArray = include_filter.split(",", false)
		var includes_word_text: bool = include_patterns.has("*.txt") or include_patterns.has("assets/words/words.txt") or include_patterns.has("res://assets/words/words.txt")
		assert_eq(export_filter, "all_resources", "Android export should continue using all_resources mode")
		assert_true(includes_word_text, "Android export include_filter must explicitly package the plain-text word list")

func test_web_export_includes_plain_text_word_list() -> void:
	var config: ConfigFile = ConfigFile.new()
	var err: Error = config.load("res://export_presets.cfg")
	assert_eq(err, OK, "export_presets.cfg should load for Web export verification")
	if err == OK:
		var export_filter: String = String(config.get_value("preset.1", "export_filter", ""))
		var include_filter: String = String(config.get_value("preset.1", "include_filter", ""))
		var include_patterns: PackedStringArray = include_filter.split(",", false)
		var includes_word_text: bool = include_patterns.has("*.txt") or include_patterns.has("assets/words/words.txt") or include_patterns.has("res://assets/words/words.txt")
		assert_eq(export_filter, "all_resources", "Web export should continue using all_resources mode")
		assert_true(includes_word_text, "Web export include_filter must explicitly package the plain-text word list")

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
