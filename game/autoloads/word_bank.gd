# autoloads/word_bank.gd
extends Node

## WordBank AutoLoad
## Manages the dictionary of valid 5-letter isogram words for LetterLogic.
## Provides O(1) word validation, duplicate letter detection, and seeded/unseeded random selection.

const WORD_LIST_PATH: String = "res://assets/words/words.txt"
const WORD_LENGTH: int = 5

var _word_list: Array[String] = []
var _word_set: Dictionary = {}
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	load_words()

## Loads and filters the word dictionary from disk.
func load_words(path: String = WORD_LIST_PATH) -> bool:
	_word_list.clear()
	_word_set.clear()
	_rng.randomize()

	if not FileAccess.file_exists(path):
		push_error("WordBank: Word list file not found at '%s'" % path)
		return false

	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("WordBank: Failed to open word list file '%s' (Error: %s)" % [path, str(FileAccess.get_open_error())])
		return false

	while not file.eof_reached():
		var line: String = file.get_line().strip_edges().to_upper()
		if line.length() == WORD_LENGTH and not has_duplicate_letters(line):
			if not _word_set.has(line):
				_word_set[line] = true
				_word_list.append(line)

	file.close()
	print_debug("WordBank: Loaded %d unique 5-letter isograms." % _word_list.size())
	return _word_list.size() > 0

## Checks if the given word contains any repeating characters.
func has_duplicate_letters(word: String) -> bool:
	var clean_word: String = word.strip_edges().to_upper()
	var seen: Dictionary = {}
	for i in range(clean_word.length()):
		var char_code: String = clean_word[i]
		if seen.has(char_code):
			return true
		seen[char_code] = true
	return false

## Validates whether a candidate guess is a valid 5-letter isogram in the dictionary.
func is_valid_word(word: String) -> bool:
	var clean_word: String = word.strip_edges().to_upper()
	if clean_word.length() != WORD_LENGTH:
		return false
	if has_duplicate_letters(clean_word):
		return false
	return _word_set.has(clean_word)

## Returns a random 5-letter isogram.
## If seed_val >= 0, uses a deterministic seeded RNG (for Daily Challenge).
func get_random_word(seed_val: int = -1) -> String:
	if _word_list.is_empty():
		push_error("WordBank: Cannot pick a word from an empty word bank.")
		return ""
	
	if seed_val >= 0:
		var seeded_rng: RandomNumberGenerator = RandomNumberGenerator.new()
		seeded_rng.seed = seed_val
		var index: int = seeded_rng.randi_range(0, _word_list.size() - 1)
		return _word_list[index]
	else:
		var index: int = _rng.randi_range(0, _word_list.size() - 1)
		return _word_list[index]

## Returns the total count of loaded words.
func get_word_count() -> int:
	return _word_list.size()

## Returns true if the dictionary has been loaded into memory.
func is_loaded() -> bool:
	return not _word_list.is_empty()
