# tests/test_game_board.gd
extends "res://tests/test_base.gd"

## Automated unit tests for GameBoard UI grid.

const GameBoardScript = preload("res://scripts/game_board.gd")
const TileScript = preload("res://scripts/tile.gd")
const GameManagerScript = preload("res://autoloads/game_manager.gd")

var board: Node = null
var game_mgr: Node = null

func _init() -> void:
	game_mgr = GameManagerScript.new()
	board = GameBoardScript.new()
	board._setup_grid()

func cleanup() -> void:
	if board != null and is_instance_valid(board):
		board.free()
		board = null
	if game_mgr != null and is_instance_valid(game_mgr):
		game_mgr.free()
		game_mgr = null

func test_grid_dimensions() -> void:
	assert_eq(board.tiles.size(), 6, "Board should have exactly 6 rows")
	for r in range(6):
		assert_eq(board.tiles[r].size(), 5, "Row %d should have exactly 5 columns" % r)

func test_set_tile_letter_and_state() -> void:
	board.set_tile_letter(0, 0, "A")
	var tile_0_0: Node = board.get_tile(0, 0)
	assert_true(tile_0_0 != null, "Tile at (0,0) should exist")
	assert_eq(tile_0_0.letter, "A", "Tile letter should be A")
	assert_eq(tile_0_0.current_state, GameManagerScript.TileState.TYPING, "State should be TYPING after setting letter")
	
	board.set_tile_state(0, 0, GameManagerScript.TileState.CORRECT)
	assert_eq(tile_0_0.current_state, GameManagerScript.TileState.CORRECT, "State should update to CORRECT")

func test_reset_board() -> void:
	board.set_tile_letter(0, 0, "X")
	board.set_tile_letter(0, 1, "Y")
	board.set_tile_state(0, 0, GameManagerScript.TileState.CORRECT)
	
	board.reset_board()
	for r in range(6):
		for c in range(5):
			var tile: Node = board.get_tile(r, c)
			assert_eq(tile.letter, "", "Tile (%d,%d) letter should be cleared" % [r, c])
			assert_eq(tile.current_state, GameManagerScript.TileState.EMPTY, "Tile (%d,%d) state should be EMPTY" % [r, c])

func test_signal_handling() -> void:
	# Test letter added
	board._on_letter_added("W", 2, 1)
	var tile: Node = board.get_tile(1, 2)
	assert_eq(tile.letter, "W", "Tile (1,2) should have letter W")
	
	# Test letter removed
	board._on_letter_removed(2, 1)
	assert_eq(tile.letter, "", "Tile (1,2) letter should be cleared after removal")
	
	# Test guess submitted
	var results: Array = [
		GameManagerScript.TileState.CORRECT,
		GameManagerScript.TileState.PRESENT,
		GameManagerScript.TileState.ABSENT,
		GameManagerScript.TileState.CORRECT,
		GameManagerScript.TileState.ABSENT
	]
	board._on_guess_submitted(0, "PLANT", results)
	assert_eq(board.get_tile(0, 0).current_state, GameManagerScript.TileState.CORRECT, "Tile (0,0) should be CORRECT")
	assert_eq(board.get_tile(0, 1).current_state, GameManagerScript.TileState.PRESENT, "Tile (0,1) should be PRESENT")
	assert_eq(board.get_tile(0, 2).current_state, GameManagerScript.TileState.ABSENT, "Tile (0,2) should be ABSENT")
	assert_eq(board.get_tile(0, 3).current_state, GameManagerScript.TileState.CORRECT, "Tile (0,3) should be CORRECT")
	assert_eq(board.get_tile(0, 4).current_state, GameManagerScript.TileState.ABSENT, "Tile (0,4) should be ABSENT")
