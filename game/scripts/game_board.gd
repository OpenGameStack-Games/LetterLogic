# scripts/game_board.gd
class_name GameBoard
extends Control

## Manages the 6x5 interactive tile grid for LetterLogic.
## Synchronizes automatically with GameManager events.

const TileScript = preload("res://scripts/tile.gd")
const GameManagerScript = preload("res://autoloads/game_manager.gd")

const ROWS: int = 6
const COLS: int = 5

var grid_container: GridContainer = null
var tiles: Array = [] # 2D array: tiles[row][col]

func _ready() -> void:
	_setup_grid()
	_connect_game_manager()

func _setup_grid() -> void:
	if not has_node("MarginContainer/AspectRatioContainer/GridContainer"):
		# In case structure is instantiated programmatically
		var margin: MarginContainer = MarginContainer.new()
		margin.name = "MarginContainer"
		margin.set_anchors_preset(PRESET_FULL_RECT)
		margin.add_theme_constant_override("margin_left", 10)
		margin.add_theme_constant_override("margin_top", 10)
		margin.add_theme_constant_override("margin_right", 10)
		margin.add_theme_constant_override("margin_bottom", 10)
		add_child(margin)
		
		var aspect: AspectRatioContainer = AspectRatioContainer.new()
		aspect.name = "AspectRatioContainer"
		aspect.size_flags_horizontal = SIZE_EXPAND_FILL
		aspect.size_flags_vertical = SIZE_EXPAND_FILL
		aspect.ratio = 0.8333
		margin.add_child(aspect)
		
		grid_container = GridContainer.new()
		grid_container.name = "GridContainer"
		grid_container.columns = COLS
		grid_container.add_theme_constant_override("h_separation", 8)
		grid_container.add_theme_constant_override("v_separation", 8)
		grid_container.size_flags_horizontal = SIZE_EXPAND_FILL
		grid_container.size_flags_vertical = SIZE_EXPAND_FILL
		aspect.add_child(grid_container)
	else:
		grid_container = $MarginContainer/AspectRatioContainer/GridContainer as GridContainer

	_build_tiles()

func _build_tiles() -> void:
	tiles.clear()
	for child in grid_container.get_children():
		child.queue_free()
	
	for r in range(ROWS):
		var row_tiles: Array = []
		for c in range(COLS):
			var tile: Node = null
			if ResourceLoader.exists("res://scenes/tile.tscn"):
				var scn: PackedScene = load("res://scenes/tile.tscn")
				if scn != null:
					tile = scn.instantiate()
			
			if tile == null:
				tile = TileScript.new()
			
			tile.size_flags_horizontal = SIZE_EXPAND_FILL
			tile.size_flags_vertical = SIZE_EXPAND_FILL
			grid_container.add_child(tile)
			row_tiles.append(tile)
		tiles.append(row_tiles)

func _connect_game_manager() -> void:
	var gm: Node = get_node_or_null("/root/GameManager") if is_inside_tree() else null
	if gm != null:
		if not gm.letter_added.is_connected(_on_letter_added):
			gm.letter_added.connect(_on_letter_added)
		if not gm.letter_removed.is_connected(_on_letter_removed):
			gm.letter_removed.connect(_on_letter_removed)
		if not gm.guess_submitted.is_connected(_on_guess_submitted):
			gm.guess_submitted.connect(_on_guess_submitted)
		if not gm.game_reset.is_connected(_on_game_reset):
			gm.game_reset.connect(_on_game_reset)

func _on_letter_added(letter: String, col: int, row: int) -> void:
	set_tile_letter(row, col, letter)

func _on_letter_removed(col: int, row: int) -> void:
	set_tile_letter(row, col, "")

func _on_guess_submitted(row: int, _guess: String, results: Array) -> void:
	for col in range(results.size()):
		var delay: float = col * 0.3 # Stagger by 0.3s
		var tile: Node = get_tile(row, col)
		if tile != null and tile.has_method("animate_reveal"):
			tile.animate_reveal(results[col], delay)
		else:
			set_tile_state(row, col, results[col])

func _on_game_reset() -> void:
	reset_board()

func set_tile_letter(row: int, col: int, letter: String) -> void:
	if row >= 0 and row < ROWS and col >= 0 and col < COLS:
		if tiles.size() > row and tiles[row].size() > col:
			var tile: Node = tiles[row][col]
			if tile != null and tile.has_method("set_letter"):
				tile.set_letter(letter)

func set_tile_state(row: int, col: int, state: int) -> void:
	if row >= 0 and row < ROWS and col >= 0 and col < COLS:
		if tiles.size() > row and tiles[row].size() > col:
			var tile: Node = tiles[row][col]
			if tile != null and tile.has_method("set_state"):
				tile.set_state(state)

func get_tile(row: int, col: int) -> Node:
	if row >= 0 and row < ROWS and col >= 0 and col < COLS:
		if tiles.size() > row and tiles[row].size() > col:
			return tiles[row][col]
	return null

func reset_board() -> void:
	for r in range(ROWS):
		for c in range(COLS):
			if tiles.size() > r and tiles[r].size() > c:
				var tile: Node = tiles[r][c]
				if tile != null and tile.has_method("reset"):
					tile.reset()

## Repopulates the board tiles and evaluation states from the current GameManager state.
func populate_from_manager(gm_override: Node = null) -> void:
	var gm: Node = gm_override if gm_override != null else (get_node_or_null("/root/GameManager") if is_inside_tree() else null)
	if gm == null:
		return
	
	reset_board()
	for r in range(mini(gm.guesses.size(), ROWS)):
		var guess: String = gm.guesses[r]
		for c in range(mini(guess.length(), COLS)):
			set_tile_letter(r, c, guess[c])
		if r < gm.guess_results.size():
			var results: Array = gm.guess_results[r]
			for c in range(mini(results.size(), COLS)):
				set_tile_state(r, c, results[c])
	
	if gm.current_row < ROWS and gm.current_guess != "":
		for c in range(mini(gm.current_guess.length(), COLS)):
			set_tile_letter(gm.current_row, c, gm.current_guess[c])
