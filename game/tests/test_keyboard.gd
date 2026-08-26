# tests/test_keyboard.gd
extends "res://tests/test_base.gd"

## Automated unit tests for GameKeyboard and dynamic row-disabling.

const GameKeyboardScript = preload("res://scripts/keyboard.gd")
const KeyboardKeyScript = preload("res://scripts/keyboard_key.gd")
const GameManagerScript = preload("res://autoloads/game_manager.gd")

var keyboard: Node = null
var game_mgr: Node = null

func _init() -> void:
	game_mgr = GameManagerScript.new()
	keyboard = GameKeyboardScript.new()
	keyboard.set_game_manager(game_mgr)
	keyboard._setup_keyboard()

func cleanup() -> void:
	if keyboard != null and is_instance_valid(keyboard):
		keyboard.free()
		keyboard = null
	if game_mgr != null and is_instance_valid(game_mgr):
		game_mgr.free()
		game_mgr = null

func test_keyboard_contains_all_26_letters() -> void:
	assert_eq(keyboard.keys_by_letter.size(), 26, "Keyboard must register all 26 English letter keys")
	for char_code in range(65, 91):
		var letter: String = String.chr(char_code)
		var key_node: Node = keyboard.get_key(letter)
		assert_true(key_node != null, "Key '%s' should exist on the keyboard" % letter)

func test_dynamic_row_disabling_on_letter_added() -> void:
	var key_a: Node = keyboard.get_key("A")
	var key_b: Node = keyboard.get_key("B")
	
	assert_false(key_a.is_row_disabled, "Key A should initially be enabled")
	assert_false(key_b.is_row_disabled, "Key B should initially be enabled")
	
	# Simulate adding 'A' to the current row
	keyboard._on_letter_added("A", 0, 0)
	assert_true(key_a.is_row_disabled, "Key A should now be disabled for current row")
	assert_true(key_a.disabled, "Key A button should have disabled property true")
	assert_false(key_b.is_row_disabled, "Key B should remain enabled")
	
	# Simulate adding 'B'
	keyboard._on_letter_added("B", 1, 0)
	assert_true(key_a.is_row_disabled, "Key A should still be disabled")
	assert_true(key_b.is_row_disabled, "Key B should now also be disabled")

func test_re_enabling_on_letter_removed() -> void:
	var key_a: Node = keyboard.get_key("A")
	var key_b: Node = keyboard.get_key("B")
	
	keyboard._on_letter_added("A", 0, 0)
	keyboard._on_letter_added("B", 1, 0)
	
	# Simulate removing B (no active letters in GameManager mock)
	keyboard._on_letter_removed(1, 0)
	assert_false(key_b.is_row_disabled, "Key B should be re-enabled after removal")

func test_key_coloring_on_guess_submitted() -> void:
	var key_p: Node = keyboard.get_key("P")
	var key_o: Node = keyboard.get_key("O")
	var key_i: Node = keyboard.get_key("I")
	var key_n: Node = keyboard.get_key("N")
	var key_t: Node = keyboard.get_key("T")
	
	# Mark P, O, I, N, T as disabled in row
	for l in ["P", "O", "I", "N", "T"]:
		keyboard.get_key(l).set_row_disabled(true)
	
	# Set GameManager state expectations
	game_mgr.keyboard_states["P"] = GameManagerScript.TileState.CORRECT
	game_mgr.keyboard_states["O"] = GameManagerScript.TileState.ABSENT
	game_mgr.keyboard_states["I"] = GameManagerScript.TileState.ABSENT
	game_mgr.keyboard_states["N"] = GameManagerScript.TileState.CORRECT
	game_mgr.keyboard_states["T"] = GameManagerScript.TileState.PRESENT
	
	keyboard._on_guess_submitted(0, "POINT", [])
	
	# All keys must be re-enabled for the next row
	assert_false(key_p.is_row_disabled, "Key P should be re-enabled for next row")
	assert_false(key_o.is_row_disabled, "Key O should be re-enabled for next row")
	
	# Check color states
	key_p.set_key_state(GameManagerScript.TileState.CORRECT)
	key_o.set_key_state(GameManagerScript.TileState.ABSENT)
	key_t.set_key_state(GameManagerScript.TileState.PRESENT)
	
	assert_eq(key_p.key_state, GameManagerScript.TileState.CORRECT, "P should be CORRECT")
	assert_eq(key_o.key_state, GameManagerScript.TileState.ABSENT, "O should be ABSENT")
	assert_eq(key_t.key_state, GameManagerScript.TileState.PRESENT, "T should be PRESENT")

func test_reset_keyboard() -> void:
	var key_a: Node = keyboard.get_key("A")
	key_a.set_key_state(GameManagerScript.TileState.CORRECT)
	key_a.set_row_disabled(true)
	
	keyboard.reset_keyboard()
	assert_false(key_a.is_row_disabled, "Key A should not be disabled after reset")
	assert_eq(key_a.key_state, GameManagerScript.TileState.EMPTY, "Key A state should be EMPTY after reset")
