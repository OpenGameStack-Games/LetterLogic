# autoloads/game_manager.gd
extends Node

## GameManager AutoLoad
## Handles the core game logic, state transitions, duplicate letter restrictions,
## guess evaluation (Wordle rules with 5-letter isograms), and events for LetterLogic.

const WordBankScript = preload("res://autoloads/word_bank.gd")

enum TileState {
	EMPTY,    # Unused tile
	TYPING,   # Letter typed in current active row, not yet submitted
	CORRECT,  # Green: Correct letter in the correct spot
	PRESENT,  # Yellow: Correct letter in the wrong spot
	ABSENT    # Dark Gray: Letter not in the secret word
}

enum GameStatus {
	IN_PROGRESS,
	WON,
	LOST
}

enum GameMode {
	CONTINUOUS,
	DAILY
}

const MAX_ROWS: int = 6
const WORD_LENGTH: int = 5

# State
var current_mode: GameMode = GameMode.CONTINUOUS
var game_status: GameStatus = GameStatus.IN_PROGRESS
var secret_word: String = ""
var current_row: int = 0
var current_guess: String = ""
var guesses: Array[String] = []
var guess_results: Array[Array] = [] # Array of Array[TileState]
var keyboard_states: Dictionary = {} # String (letter) -> TileState

var _word_bank_ref: Node = null

# Signals
signal game_started(mode: GameMode, secret: String)
signal letter_added(letter: String, col: int, row: int)
signal letter_removed(col: int, row: int)
signal guess_submitted(row: int, guess: String, results: Array[TileState])
signal invalid_guess(reason: String)
signal game_won(attempts: int, secret: String)
signal game_lost(secret: String)
signal game_reset()

func _ready() -> void:
	_init_word_bank()

func _init_word_bank() -> void:
	if _word_bank_ref != null and is_instance_valid(_word_bank_ref):
		return
	if get_node_or_null("/root/WordBank") != null:
		_word_bank_ref = get_node("/root/WordBank")
	else:
		var wb: Node = WordBankScript.new()
		wb.name = "WordBank"
		add_child(wb)
		_word_bank_ref = wb

func set_word_bank(wb: Node) -> void:
	_word_bank_ref = wb

func get_word_bank() -> Node:
	_init_word_bank()
	return _word_bank_ref

## Starts a new game session.
## If target_word is empty, picks a random word from WordBank.
func start_game(mode: GameMode = GameMode.CONTINUOUS, target_word: String = "") -> void:
	current_mode = mode
	current_row = 0
	current_guess = ""
	guesses.clear()
	guess_results.clear()
	keyboard_states.clear()
	game_status = GameStatus.IN_PROGRESS
	
	if target_word != "":
		secret_word = target_word.strip_edges().to_upper()
	else:
		var wb: Node = get_word_bank()
		if wb != null and wb.has_method("is_loaded") and wb.is_loaded():
			secret_word = wb.get_random_word()
		else:
			secret_word = "LOGIC" # Fallback
	
	print_debug("GameManager: Started game in mode %s with secret word length %d" % [
		"DAILY" if mode == GameMode.DAILY else "CONTINUOUS",
		secret_word.length()
	])
	game_started.emit(current_mode, secret_word)
	game_reset.emit()

## Adds a letter to the current active guess row.
## Enforces: (1) Max 5 letters, (2) No duplicate letters in current row, (3) Game in progress.
func add_letter(letter: String) -> bool:
	if game_status != GameStatus.IN_PROGRESS:
		return false
	if current_guess.length() >= WORD_LENGTH:
		return false
	
	var char_to_add: String = letter.strip_edges().to_upper()
	if char_to_add.length() != 1 or not char_to_add[0].is_subsequence_of("ABCDEFGHIJKLMNOPQRSTUVWXYZ"):
		return false
	
	# RULE: Letter cannot already be in the active unsubmitted row
	if current_guess.contains(char_to_add):
		invalid_guess.emit("Duplicate letter in current guess")
		return false
	
	var col: int = current_guess.length()
	current_guess += char_to_add
	letter_added.emit(char_to_add, col, current_row)
	return true

## Removes the last typed letter from the current active guess row.
func remove_letter() -> bool:
	if game_status != GameStatus.IN_PROGRESS:
		return false
	if current_guess.is_empty():
		return false
	
	var col_to_remove: int = current_guess.length() - 1
	current_guess = current_guess.substr(0, col_to_remove)
	letter_removed.emit(col_to_remove, current_row)
	return true

## Submits the current guess.
## Returns a Dictionary with: { "success": bool, "reason": String, "results": Array[TileState] }
func submit_guess() -> Dictionary:
	if game_status != GameStatus.IN_PROGRESS:
		return { "success": false, "reason": "Game is already over", "results": [] }
	
	if current_guess.length() != WORD_LENGTH:
		invalid_guess.emit("Word must be 5 letters")
		return { "success": false, "reason": "Word must be 5 letters", "results": [] }
	
	var wb: Node = get_word_bank()
	if wb != null and wb.has_method("is_valid_word") and not wb.is_valid_word(current_guess):
		invalid_guess.emit("Not in word list")
		return { "success": false, "reason": "Not in word list", "results": [] }
	
	var results: Array[TileState] = evaluate_guess(current_guess, secret_word)
	guesses.append(current_guess)
	guess_results.append(results)
	_update_keyboard_states(current_guess, results)
	
	var submitted_row: int = current_row
	var submitted_word: String = current_guess
	current_guess = ""
	current_row += 1
	
	guess_submitted.emit(submitted_row, submitted_word, results)
	
	if submitted_word == secret_word:
		game_status = GameStatus.WON
		game_won.emit(submitted_row + 1, secret_word)
	elif current_row >= MAX_ROWS:
		game_status = GameStatus.LOST
		game_lost.emit(secret_word)
	
	return { "success": true, "reason": "", "results": results }

## Evaluates a guess string against the secret word.
## Since all secret words and valid guesses are isograms, each letter is either:
## - CORRECT (matching character and position)
## - PRESENT (character is in secret word, but different position)
## - ABSENT (character is not in secret word)
func evaluate_guess(guess: String, secret: String) -> Array[TileState]:
	var results: Array[TileState] = []
	var upper_guess: String = guess.to_upper()
	var upper_secret: String = secret.to_upper()
	
	for i in range(WORD_LENGTH):
		var guess_char: String = upper_guess[i]
		if guess_char == upper_secret[i]:
			results.append(TileState.CORRECT)
		elif upper_secret.contains(guess_char):
			results.append(TileState.PRESENT)
		else:
			results.append(TileState.ABSENT)
			
	return results

## Updates the best-known tile state for each letter on the keyboard.
## Ranking: CORRECT > PRESENT > ABSENT
func _update_keyboard_states(guess: String, results: Array[TileState]) -> void:
	for i in range(results.size()):
		var letter: String = guess[i]
		var new_state: TileState = results[i]
		
		if not keyboard_states.has(letter):
			keyboard_states[letter] = new_state
		else:
			var existing_state: TileState = keyboard_states[letter]
			if new_state == TileState.CORRECT:
				keyboard_states[letter] = TileState.CORRECT
			elif new_state == TileState.PRESENT and existing_state != TileState.CORRECT:
				keyboard_states[letter] = TileState.PRESENT
			elif new_state == TileState.ABSENT and existing_state == TileState.EMPTY:
				keyboard_states[letter] = TileState.ABSENT

## Returns the array of letters currently typed in the active row (for keyboard disabling).
func get_typed_letters_in_current_row() -> Array[String]:
	var result: Array[String] = []
	for i in range(current_guess.length()):
		result.append(current_guess[i])
	return result

## Returns the keyboard letter state for a specific character.
func get_letter_state(letter: String) -> TileState:
	var upper: String = letter.to_upper()
	if keyboard_states.has(upper):
		return keyboard_states[upper]
	return TileState.EMPTY
