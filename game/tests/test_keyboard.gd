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

func test_absent_and_disabled_key_colors() -> void:
	var key_k: Node = keyboard.get_key("K")
	assert_eq(key_k.COLOR_BG_ABSENT.to_html(false).to_lower(), "b53b3b", "KeyboardKey absent bg color should be flat red (#b53b3b)")
	assert_eq(key_k.COLOR_TEXT_ABSENT.to_html(false).to_lower(), "ffffff", "KeyboardKey absent text color should be white (#ffffff)")
	
	# Verify visual stylebox when state is ABSENT
	key_k.set_key_state(GameManagerScript.TileState.ABSENT)
	var style_absent: StyleBoxFlat = key_k.get_theme_stylebox("normal") as StyleBoxFlat
	assert_true(style_absent != null, "Stylebox for absent key should exist")
	if style_absent != null:
		assert_eq(style_absent.bg_color.to_html(false).to_lower(), "b53b3b", "Absent key bg color should be flat red")
	assert_eq(key_k.get_theme_color("font_color").to_html(false).to_lower(), "ffffff", "Absent key text color should be white")
	
	# Verify distinct disabled styling when typed in active row
	key_k.set_row_disabled(true)
	var style_disabled: StyleBoxFlat = key_k.get_theme_stylebox("normal") as StyleBoxFlat
	if style_disabled != null:
		assert_eq(style_disabled.bg_color.to_html(false).to_lower(), "272729", "Row-disabled key should remain distinctly dark gray (#272729)")
	assert_eq(key_k.get_theme_color("font_color").to_html(false).to_lower(), "505050", "Row-disabled key text should remain dark (#505050)")

func test_keyboard_key_dimensions_and_typography() -> void:
	var key_a: Node = keyboard.get_key("A")
	assert_eq(KeyboardKeyScript.KEY_MIN_TOUCH_HEIGHT, 44.0, "Keyboard keys should use a 44px absolute touch target floor")
	assert_eq(key_a.custom_minimum_size.y, 44.0, "Key minimum height should be the flexible touch target floor")
	assert_true(key_a.get_theme_font_size("font_size") >= KeyboardKeyScript.FONT_SIZE_LETTER_MIN, "Standard letter key font size should stay readable at minimum height")

	var key_enter: Button = null
	var key_del: Button = null
	for c: Node in keyboard.vbox_container.get_children():
		if c is HBoxContainer:
			for b: Node in c.get_children():
				if b is Button:
					if b.text == "ENTER":
						key_enter = b
					elif b.text == "⌫":
						key_del = b

	assert_true(key_enter != null, "Enter key should exist")
	if key_enter != null:
		assert_true(key_enter.get_theme_font_size("font_size") >= KeyboardKeyScript.FONT_SIZE_ENTER_MIN and key_enter.get_theme_font_size("font_size") <= KeyboardKeyScript.FONT_SIZE_ENTER_MAX, "Enter key font size should be responsive but constrained")
	
	assert_true(key_del != null, "Delete key should exist")
	if key_del != null:
		assert_true(key_del.get_theme_font_size("font_size") >= KeyboardKeyScript.FONT_SIZE_DELETE_MIN, "Delete key font size should stay readable at minimum height")

func test_keyboard_runtime_bottom_margin_is_dynamic_and_safe() -> void:
	var margin_container: MarginContainer = keyboard.get_node_or_null("MarginContainer") as MarginContainer
	assert_true(margin_container != null, "Runtime keyboard MarginContainer should exist")
	if margin_container != null:
		var bottom_margin: int = margin_container.get_theme_constant("margin_bottom")
		assert_true(bottom_margin >= GameKeyboardScript.KEYBOARD_BOTTOM_MARGIN_MIN, "Runtime keyboard bottom margin should keep breathing room")
		assert_true(bottom_margin <= GameKeyboardScript.KEYBOARD_BOTTOM_MARGIN_MAX, "Runtime keyboard bottom margin should not reserve rigid oversized space")

func test_keyboard_scene_uses_flexible_flow_sizing() -> void:
	var keyboard_scene: PackedScene = load("res://scenes/keyboard.tscn") as PackedScene
	assert_true(keyboard_scene != null, "keyboard.tscn must be loadable")
	
	var scene_keyboard: Control = keyboard_scene.instantiate() as Control
	assert_true(scene_keyboard != null, "Keyboard scene should instantiate as a Control")
	if scene_keyboard == null:
		return
	
	var margin_container: MarginContainer = scene_keyboard.get_node_or_null("MarginContainer") as MarginContainer
	assert_true(margin_container != null, "Keyboard scene MarginContainer should exist")
	if margin_container != null:
		assert_true(margin_container.get_theme_constant("margin_bottom") <= GameKeyboardScript.KEYBOARD_BOTTOM_MARGIN_MAX, "Keyboard scene bottom margin should be capped for constrained screens")
	
	assert_eq(scene_keyboard.anchor_top, 0.0, "Keyboard scene should start at the top of its parent instead of using bottom anchoring")
	assert_eq(scene_keyboard.anchor_bottom, 1.0, "Keyboard scene should fill to the bottom of its parent")
	assert_eq(scene_keyboard.offset_top, 0.0, "Keyboard scene should not use absolute top offsets")
	assert_eq(scene_keyboard.size_flags_vertical, Control.SIZE_SHRINK_BEGIN, "Keyboard scene should use shrink begin for flow-layout slot")
	scene_keyboard._ready()
	assert_eq(scene_keyboard.custom_minimum_size.y, 0.0, "Keyboard scene should not enforce a rigid custom minimum height")
	assert_true(scene_keyboard.get_combined_minimum_size().y <= 164.0, "Keyboard combined minimum height should be flexible rather than 300px+")
	scene_keyboard.free()

func test_main_game_uses_flow_based_keyboard_wrapper() -> void:
	var main_scene: PackedScene = load("res://scenes/main_game.tscn") as PackedScene
	assert_true(main_scene != null, "main_game.tscn must be loadable")
	
	var main_game: Node = main_scene.instantiate()
	assert_true(main_game != null, "Main game scene should instantiate")
	if main_game == null:
		return
	
	var vbox: VBoxContainer = main_game.get_node_or_null("ContentMargin/VBoxContainer") as VBoxContainer
	assert_true(vbox != null, "Main game content VBoxContainer should exist")
	var board_area: Control = main_game.get_node_or_null("ContentMargin/VBoxContainer/BoardArea") as Control
	var keyboard_area: MarginContainer = main_game.get_node_or_null("ContentMargin/VBoxContainer/KeyboardArea") as MarginContainer
	assert_true(board_area != null, "Main game BoardArea should exist")
	assert_true(keyboard_area != null, "Main game KeyboardArea should exist")
	if board_area != null and keyboard_area != null:
		assert_eq(board_area.get_parent(), keyboard_area.get_parent(), "BoardArea and KeyboardArea should be siblings in one VBoxContainer flow")
		assert_true(board_area.get_index() < keyboard_area.get_index(), "BoardArea should appear before KeyboardArea in the vertical flow")
		assert_true(board_area is AspectRatioContainer, "BoardArea should be an AspectRatioContainer")
		assert_true(keyboard_area.custom_minimum_size.y >= 160.0, "KeyboardArea should reserve a proportional usable minimum height")
		assert_eq(keyboard_area.size_flags_vertical, Control.SIZE_EXPAND_FILL, "KeyboardArea should participate in proportional MainGame vertical flow")
	
	main_game.free()

func test_font_size_retained_after_state_change() -> void:
	var key_a: Node = keyboard.get_key("A")
	var initial_font_size: int = key_a.get_theme_font_size("font_size")
	key_a.set_key_state(GameManagerScript.TileState.CORRECT)
	assert_eq(key_a.get_theme_font_size("font_size"), initial_font_size, "Font size should be retained after CORRECT state change")
	key_a.set_row_disabled(true)
	assert_eq(key_a.get_theme_font_size("font_size"), initial_font_size, "Font size should be retained after row disabled")
	key_a.reset()
	assert_eq(key_a.get_theme_font_size("font_size"), initial_font_size, "Font size should be retained after reset")

func test_keyboard_row_3_key_order() -> void:
	var row_3: HBoxContainer = keyboard.vbox_container.get_node_or_null("Row3") as HBoxContainer
	assert_true(row_3 != null, "Row3 should exist on keyboard")
	if row_3 != null:
		var buttons: Array = []
		for child: Node in row_3.get_children():
			if child is Button:
				buttons.append(child)
		assert_eq(buttons.size(), 9, "Row3 should contain 9 keys (Delete, 7 letters, Enter)")
		if buttons.size() >= 2:
			assert_eq(buttons[0].text, "⌫", "First key on bottom row should be Delete/Backspace (left)")
			assert_eq(buttons[-1].text, "ENTER", "Last key on bottom row should be Enter (right)")

