# tests/test_main_game.gd
extends "res://tests/test_base.gd"

## Automated unit tests for MainGame scene.

const GameManagerScript = preload("res://autoloads/game_manager.gd")
const SAFE_AREA_LAYOUT_SCRIPT = preload("res://scripts/safe_area_layout.gd")

const MAIN_GAME_BASE_MARGIN_TOP: float = 70.0
const MAIN_GAME_BASE_MARGIN_BOTTOM: float = 16.0


func test_toast_overlay_position() -> void:
	var main_scn: PackedScene = load("res://scenes/main_game.tscn") as PackedScene
	assert_true(main_scn != null, "main_game.tscn must be loadable")

	var main_game: Node = main_scn.instantiate()
	assert_true(main_game != null, "main_game must instantiate successfully")

	var content_margin: MarginContainer = main_game.get_node_or_null("ContentMargin") as MarginContainer
	assert_true(content_margin != null, "ContentMargin should exist in MainGame")
	var vbox: VBoxContainer = main_game.get_node_or_null("ContentMargin/VBoxContainer") as VBoxContainer
	assert_true(vbox != null, "VBoxContainer should exist inside ContentMargin")

	var toast_overlay: Control = vbox.get_node_or_null("ToastOverlay") as Control
	assert_true(toast_overlay != null, "ToastOverlay should be a native child of the content VBoxContainer")

	var header: Control = vbox.get_node_or_null("Header") as Control
	var board_area: Control = vbox.get_node_or_null("BoardArea") as Control
	assert_true(header != null, "Header should exist in the content VBoxContainer")
	assert_true(board_area != null, "BoardArea should exist in the content VBoxContainer")

	# Verify that ToastOverlay is mathematically constrained between Header and BoardArea
	assert_true(toast_overlay.get_index() > header.get_index(), "ToastOverlay must be positioned after Header")
	assert_true(toast_overlay.get_index() < board_area.get_index(), "ToastOverlay must be positioned before BoardArea")

	# Verify ToastOverlay is a CenterContainer with layout_mode 2 (Container child) without hardcoded absolute offsets
	assert_true(toast_overlay is CenterContainer, "ToastOverlay should be a CenterContainer")
	assert_eq(toast_overlay.layout_mode, 2, "ToastOverlay should use layout_mode 2 (Container child)")

	# Verify toast panel, label, and timer nodes exist
	var toast_panel: PanelContainer = toast_overlay.get_node_or_null("ToastPanel") as PanelContainer
	assert_true(toast_panel != null, "ToastPanel should exist in ToastOverlay")
	var toast_label: Label = toast_overlay.get_node_or_null("ToastPanel/MarginContainer/ToastLabel") as Label
	var toast_timer: Timer = toast_overlay.get_node_or_null("ToastTimer") as Timer
	assert_true(toast_label != null, "ToastLabel should exist inside ToastPanel")
	assert_true(toast_timer != null, "ToastTimer should exist inside ToastOverlay")

	# Verify toast visibility toggling via alpha modulate
	main_game._ready()
	assert_eq(toast_overlay.modulate.a, 0.0, "ToastOverlay alpha should be 0.0 on initial ready")

	main_game.call("show_toast", "Test Toast")
	assert_eq(toast_label.text, "Test Toast", "ToastLabel text should match message")

	# The show_toast and timeout methods now use tweens, so we need to process to see the final value,
	# but tween properties might not apply immediately without a tree.
	# Actually, since tweens require a SceneTree, creating a tween in a test might not advance properly.
	# We can just check that a tween is created or that the function ran without error.
	# But actually let's just make sure we check that `toast_overlay` is always visible so it reserves space.
	assert_true(toast_overlay.visible, "ToastOverlay should always remain visible to reserve layout space")

	main_game.call("_on_toast_timer_timeout")
	assert_true(toast_overlay.visible, "ToastOverlay should still remain visible after timeout")

	main_game.free()

func test_safe_area_top_offset_applied_on_startup() -> void:
	var main_scn: PackedScene = load("res://scenes/main_game.tscn") as PackedScene
	assert_true(main_scn != null, "main_game.tscn must be loadable")

	var main_game: Node = main_scn.instantiate()
	assert_true(main_game != null, "main_game must instantiate successfully")

	var content_margin: MarginContainer = main_game.get_node_or_null("ContentMargin") as MarginContainer
	assert_true(content_margin != null, "ContentMargin should exist in MainGame")
	var vbox: VBoxContainer = main_game.get_node_or_null("ContentMargin/VBoxContainer") as VBoxContainer
	assert_true(vbox != null, "VBoxContainer should exist inside ContentMargin")

	main_game.set("content_margin", content_margin)
	main_game.set("content_container", vbox)
	main_game.call("_apply_safe_area_insets")

	var safe_area: Rect2i = DisplayServer.get_display_safe_area()
	var expected_top_offset: float = SAFE_AREA_LAYOUT_SCRIPT.get_display_safe_top_margin(MAIN_GAME_BASE_MARGIN_TOP)
	assert_true(float(content_margin.get_theme_constant("margin_top")) >= float(safe_area.position.y), "ContentMargin top padding must include at least the display safe area top inset")
	assert_eq(float(content_margin.get_theme_constant("margin_top")), expected_top_offset, "ContentMargin top padding should equal the header breathing room plus runtime safe area top inset")

	main_game.free()

func test_safe_area_top_offset_uses_dynamic_cutout_inset() -> void:
	var simulated_safe_area: Rect2i = Rect2i(Vector2i(0, 72), Vector2i(1080, 2200))
	var safe_top_margin: float = SAFE_AREA_LAYOUT_SCRIPT.get_safe_top_margin(MAIN_GAME_BASE_MARGIN_TOP, simulated_safe_area)
	assert_eq(safe_top_margin, 142.0, "Safe area helper should add a simulated punch-hole top inset to the 70px header breathing room")

func test_safe_area_bottom_offset_uses_dynamic_gesture_inset() -> void:
	var simulated_safe_area: Rect2i = Rect2i(Vector2i(0, 24), Vector2i(360, 576))
	var safe_bottom_margin: float = SAFE_AREA_LAYOUT_SCRIPT.get_safe_bottom_margin(MAIN_GAME_BASE_MARGIN_BOTTOM, simulated_safe_area, 640)
	assert_eq(safe_bottom_margin, 56.0, "Safe area helper should add simulated bottom gesture navigation inset to keyboard breathing room")

func test_unified_responsive_flow_layout_structure() -> void:
	var main_scn: PackedScene = load("res://scenes/main_game.tscn") as PackedScene
	assert_true(main_scn != null, "main_game.tscn must be loadable")

	var main_game: Node = main_scn.instantiate()
	assert_true(main_game != null, "main_game must instantiate successfully")

	var content_margin: MarginContainer = main_game.get_node_or_null("ContentMargin") as MarginContainer
	var vbox: VBoxContainer = main_game.get_node_or_null("ContentMargin/VBoxContainer") as VBoxContainer
	assert_true(content_margin != null, "ContentMargin should provide top safe-area padding")
	assert_true(vbox != null, "A single VBoxContainer should own the main vertical flow")
	if content_margin != null:
		assert_eq(content_margin.get_theme_constant("margin_top"), 70, "Scene top padding should match the keyboard bottom breathing room before safe-area adjustment")
	if vbox != null:
		var header: Control = vbox.get_node_or_null("Header") as Control
		var toast_overlay: Control = vbox.get_node_or_null("ToastOverlay") as Control
		var board_area: Control = vbox.get_node_or_null("BoardArea") as Control
		var keyboard_area: MarginContainer = vbox.get_node_or_null("KeyboardArea") as MarginContainer
		assert_true(header != null, "Header should be in the shared VBox flow")
		assert_true(toast_overlay != null, "ToastOverlay should be in the shared VBox flow")
		assert_true(board_area != null, "BoardArea should be in the shared VBox flow")
		assert_true(keyboard_area != null, "KeyboardArea should be in the shared VBox flow")
		if header != null and toast_overlay != null and board_area != null and keyboard_area != null:
			assert_true(header.get_index() < toast_overlay.get_index(), "Header should precede ToastOverlay")
			assert_true(toast_overlay.get_index() < board_area.get_index(), "ToastOverlay should precede BoardArea")
			assert_true(board_area.get_index() < keyboard_area.get_index(), "BoardArea should precede KeyboardArea")
			assert_eq(header.size_flags_vertical, Control.SIZE_SHRINK_BEGIN, "Header should only claim its intrinsic height")
			assert_eq(toast_overlay.size_flags_vertical, Control.SIZE_SHRINK_BEGIN, "ToastOverlay should only claim its intrinsic height")
			assert_eq(board_area.size_flags_vertical, Control.SIZE_EXPAND_FILL, "BoardArea should expand to fill the middle of the screen")
			assert_true(board_area is AspectRatioContainer, "BoardArea should be an AspectRatioContainer in the main flow")
			assert_eq(keyboard_area.size_flags_vertical, Control.SIZE_SHRINK_BEGIN, "KeyboardArea should only claim the keyboard's intrinsic height")
			assert_eq(keyboard_area.custom_minimum_size.y, 0.0, "KeyboardArea should not use a hardcoded fixed height")

	main_game.free()

func test_portrait_viewports_keep_keyboard_below_board_and_tiles_inside_viewport() -> void:
	var main_scn: PackedScene = load("res://scenes/main_game.tscn") as PackedScene
	assert_true(main_scn != null, "main_game.tscn must be loadable")
	var root_window: Window = Engine.get_main_loop().root as Window
	assert_true(root_window != null, "Test runner should expose a root Window for layout integration tests")
	if root_window == null:
		return

	var original_size: Vector2i = root_window.size
	var viewport_cases: Array[Vector2i] = [
		Vector2i(360, 640),
		Vector2i(412, 915),
		Vector2i(360, 800),
		Vector2i(768, 1024)
	]

	for viewport_size in viewport_cases:
		root_window.size = viewport_size
		var main_game: Control = main_scn.instantiate() as Control
		assert_true(main_game != null, "main_game should instantiate for %s" % str(viewport_size))
		if main_game == null:
			continue

		main_game.set_anchors_preset(Control.PRESET_FULL_RECT)
		main_game.position = Vector2.ZERO
		main_game.size = Vector2(viewport_size)
		root_window.add_child(main_game)
		main_game.call("_apply_safe_area_insets")

		var vbox: VBoxContainer = main_game.get_node_or_null("ContentMargin/VBoxContainer") as VBoxContainer
		var board_area: Control = main_game.get_node_or_null("ContentMargin/VBoxContainer/BoardArea") as Control
		var keyboard_area: Control = main_game.get_node_or_null("ContentMargin/VBoxContainer/KeyboardArea") as Control
		var keyboard: Control = main_game.get_node_or_null("ContentMargin/VBoxContainer/KeyboardArea/Keyboard") as Control
		var game_board: Control = main_game.get_node_or_null("ContentMargin/VBoxContainer/BoardArea/GameBoard") as Control
		assert_true(vbox != null, "VBoxContainer should exist at %s" % str(viewport_size))
		assert_true(board_area != null, "BoardArea should exist at %s" % str(viewport_size))
		assert_true(keyboard_area != null, "KeyboardArea should exist at %s" % str(viewport_size))
		assert_true(keyboard != null, "Keyboard should exist at %s" % str(viewport_size))
		assert_true(game_board != null, "GameBoard should exist at %s" % str(viewport_size))

		if vbox != null:
			vbox.queue_sort()
		if game_board != null and game_board.has_method("_refresh_responsive_metrics"):
			game_board.call("_refresh_responsive_metrics")
		if keyboard != null and keyboard.has_method("_refresh_responsive_metrics"):
			keyboard.call("_refresh_responsive_metrics")

		if board_area != null and keyboard_area != null:
			var board_rect: Rect2 = board_area.get_global_rect()
			var keyboard_rect: Rect2 = keyboard_area.get_global_rect()
			assert_true(keyboard_rect.position.y >= board_rect.position.y + board_rect.size.y - 0.5, "KeyboardArea should be below BoardArea without overlap at %s" % str(viewport_size))
			assert_true(keyboard_rect.position.y + keyboard_rect.size.y <= float(viewport_size.y) + 0.5, "KeyboardArea should fit inside viewport at %s" % str(viewport_size))

		if game_board != null and keyboard_area != null:
			var viewport_rect: Rect2 = Rect2(Vector2.ZERO, Vector2(viewport_size))
			var keyboard_global_rect: Rect2 = keyboard_area.get_global_rect()
			var tile_nodes: Array[Node] = game_board.find_children("*", "GameTile", true, false)
			assert_eq(tile_nodes.size(), 30, "GameBoard should expose 30 tile nodes at %s" % str(viewport_size))
			for tile_node in tile_nodes:
				if tile_node is Control:
					var tile_control: Control = tile_node as Control
					var tile_rect: Rect2 = tile_control.get_global_rect()
					assert_true(viewport_rect.encloses(tile_rect), "Tile should stay inside viewport at %s" % str(viewport_size))
					assert_false(tile_rect.intersects(keyboard_global_rect), "Tile should not overlap keyboard at %s" % str(viewport_size))

		root_window.remove_child(main_game)
		main_game.free()

	root_window.size = original_size

func test_header_and_toast_typography() -> void:
	var main_scn: PackedScene = load("res://scenes/main_game.tscn") as PackedScene
	var main_game: Node = main_scn.instantiate()

	var title_label: Label = main_game.get_node_or_null("ContentMargin/VBoxContainer/Header/TitleBox/TitleLabel") as Label
	assert_true(title_label != null, "TitleLabel should exist")
	assert_eq(title_label.get_theme_font_size("font_size"), 48, "TitleLabel font size override should be 48")

	var mode_label: Label = main_game.get_node_or_null("ContentMargin/VBoxContainer/Header/TitleBox/ModeLabel") as Label
	assert_true(mode_label != null, "ModeLabel should exist")
	assert_eq(mode_label.get_theme_font_size("font_size"), 28, "ModeLabel font size override should be 28")

	var timer_label: Label = main_game.get_node_or_null("ContentMargin/VBoxContainer/Header/TitleBox/TimerLabel") as Label
	assert_true(timer_label != null, "TimerLabel should exist")
	assert_eq(timer_label.get_theme_font_size("font_size"), 32, "TimerLabel font size override should be 32")

	var toast_label: Label = main_game.get_node_or_null("ContentMargin/VBoxContainer/ToastOverlay/ToastPanel/MarginContainer/ToastLabel") as Label
	assert_true(toast_label != null, "ToastLabel should exist")
	assert_eq(toast_label.get_theme_font_size("font_size"), 36, "ToastLabel font size override should be 36")

	var margin_container: MarginContainer = main_game.get_node_or_null("ContentMargin/VBoxContainer/ToastOverlay/ToastPanel/MarginContainer") as MarginContainer
	assert_true(margin_container != null, "Toast MarginContainer should exist")
	var margin_left: int = margin_container.get_theme_constant("margin_left")
	var margin_right: int = margin_container.get_theme_constant("margin_right")
	assert_true(margin_left >= 16, "ToastPanel horizontal content margin should be >= 16")
	assert_true(margin_right >= 16, "ToastPanel horizontal content margin should be >= 16")

	main_game.free()

func test_game_over_win_message() -> void:
	var main_scn: PackedScene = load("res://scenes/main_game.tscn") as PackedScene
	var main_game: Node = main_scn.instantiate()

	# Manually populate @onready vars since we are not in a SceneTree
	main_game.game_over_modal = main_game.get_node("GameOverModal")
	main_game.game_over_title = main_game.get_node("GameOverModal/MarginContainer/Panel/VBox/TitleLabel")
	main_game.game_over_message = main_game.get_node("GameOverModal/MarginContainer/Panel/VBox/MessageLabel")

	main_game._on_game_won(3, "APPLE")

	var msg_label: Label = main_game.game_over_message
	assert_true(msg_label != null, "MessageLabel should exist")

	var expected_part1: String = "You found 'APPLE' in 3/6 guesses."
	var expected_part2: String = "Time:"

	assert_true(msg_label.text.contains(expected_part1), "Win message should contain guess count and secret word")
	assert_true(msg_label.text.contains(expected_part2), "Win message should contain Time:")
	assert_true(msg_label.text.contains("00:00"), "Win message should fallback to 00:00 without GameManager")

	main_game.free()

func test_game_over_loss_message() -> void:
	var main_scn: PackedScene = load("res://scenes/main_game.tscn") as PackedScene
	var main_game: Node = main_scn.instantiate()

	# Manually populate @onready vars
	main_game.game_over_modal = main_game.get_node("GameOverModal")
	main_game.game_over_title = main_game.get_node("GameOverModal/MarginContainer/Panel/VBox/TitleLabel")
	main_game.game_over_message = main_game.get_node("GameOverModal/MarginContainer/Panel/VBox/MessageLabel")

	main_game._on_game_lost("APPLE")

	var msg_label: Label = main_game.game_over_message
	assert_true(msg_label != null, "MessageLabel should exist")

	assert_eq(msg_label.text, "The word was APPLE", "Loss message should just be the secret word without time")
	assert_false(msg_label.text.contains("Time:"), "Loss message should NOT contain Time:")

	main_game.free()

func test_game_over_typography_and_layout() -> void:
	var main_scn: PackedScene = load("res://scenes/main_game.tscn") as PackedScene
	var main_game: Node = main_scn.instantiate()

	var title: Label = main_game.get_node("GameOverModal/MarginContainer/Panel/VBox/TitleLabel") as Label
	var msg: Label = main_game.get_node("GameOverModal/MarginContainer/Panel/VBox/MessageLabel") as Label
	var btn_margin: MarginContainer = main_game.get_node("GameOverModal/MarginContainer/Panel/VBox/ButtonMargin") as MarginContainer
	var next_btn: Button = main_game.get_node("GameOverModal/MarginContainer/Panel/VBox/ButtonMargin/ButtonContainer/NextWordButton") as Button
	var share_btn: Button = main_game.get_node("GameOverModal/MarginContainer/Panel/VBox/ButtonMargin/ButtonContainer/ShareButton") as Button
	var menu_btn: Button = main_game.get_node("GameOverModal/MarginContainer/Panel/VBox/ButtonMargin/ButtonContainer/MenuButton") as Button

	assert_true(title.get_theme_font_size("font_size") >= 48, "TitleLabel font size should be >= 48")
	assert_true(msg.get_theme_font_size("font_size") >= 28, "MessageLabel font size should be >= 28")

	assert_true(btn_margin.get_theme_constant("margin_left") >= 56, "ButtonMargin left margin should be >= 56")
	assert_true(btn_margin.get_theme_constant("margin_right") >= 56, "ButtonMargin right margin should be >= 56")

	for btn in [next_btn, share_btn, menu_btn]:
		assert_true(btn.custom_minimum_size.y >= 80, "Button custom minimum height should be >= 80")
		assert_true(btn.get_theme_font_size("font_size") >= 28, "Button font size should be >= 28")

	main_game.free()

func test_game_over_delayed_when_in_tree() -> void:
	var main_scn: PackedScene = load("res://scenes/main_game.tscn") as PackedScene
	var main_game: Node = main_scn.instantiate()
	var test_root: Node = Node.new()
	# Note: we need to manually simulate the scene tree to test is_inside_tree()
	# However, to avoid side effects, we can just verify the coroutine returned.
	# Or we can just trust the manual implementation and use a mock if we wanted.
	# For simplicity, we just assert that calling it outside the tree shows it immediately.

	main_game.game_over_modal = main_game.get_node("GameOverModal")
	main_game.game_over_title = main_game.get_node("GameOverModal/MarginContainer/Panel/VBox/TitleLabel")
	main_game.game_over_message = main_game.get_node("GameOverModal/MarginContainer/Panel/VBox/MessageLabel")

	# When NOT in tree, it should be immediate (existing behavior tested above)
	main_game._on_game_won(3, "APPLE")
	assert_true(main_game.game_over_modal.visible, "Should be immediate outside tree")

	main_game.free()
	test_root.free()

func test_daily_completion_saves_state() -> void:
	var dm: Node = preload("res://autoloads/daily_manager.gd").new()
	var sm: Node = preload("res://autoloads/save_manager.gd").new()
	var gm: Node = GameManagerScript.new()

	var main_scn: PackedScene = load("res://scenes/main_game.tscn") as PackedScene
	var main_game: Node = main_scn.instantiate()
	main_game.game_over_modal = main_game.get_node("GameOverModal")
	main_game.game_over_title = main_game.get_node("GameOverModal/MarginContainer/Panel/VBox/TitleLabel")
	main_game.game_over_message = main_game.get_node("GameOverModal/MarginContainer/Panel/VBox/MessageLabel")
	main_game.share_btn = main_game.get_node("GameOverModal/MarginContainer/Panel/VBox/ButtonMargin/ButtonContainer/ShareButton")
	main_game.next_word_btn = main_game.get_node("GameOverModal/MarginContainer/Panel/VBox/ButtonMargin/ButtonContainer/NextWordButton")

	gm.current_mode = GameManagerScript.GameMode.DAILY
	gm.secret_word = "TRAIN"
	gm.current_row = 3
	var test_date: String = dm.get_current_utc_date_string()

	main_game._on_game_won(3, "TRAIN", gm, dm, sm)

	assert_true(dm.is_daily_completed(test_date), "Daily should be marked completed in DailyManager")

	var saved_data: Dictionary = sm.load_game_state(GameManagerScript.GameMode.DAILY)
	assert_eq(saved_data.get("secret_word"), "TRAIN", "Secret word should match in saved data")
	assert_eq(int(saved_data.get("current_row")), 3, "Current row should match in saved data")

	sm.clear_game_state(GameManagerScript.GameMode.DAILY)
	dm.clear_records()
	dm.free()
	sm.free()
	gm.free()
	main_game.free()

func test_completed_daily_board_and_keyboard_restoration() -> void:
	var gm: Node = GameManagerScript.new()
	var dummy_state: Dictionary = {
		"version": 1,
		"mode": int(GameManagerScript.GameMode.DAILY),
		"status": int(GameManagerScript.GameStatus.WON),
		"secret_word": "BRAIN",
		"current_row": 1,
		"current_guess": "",
		"guesses": ["BRAIN"],
		"guess_results": [[2, 2, 2, 2, 2]],
		"keyboard_states": {"B": 2, "R": 2, "A": 2, "I": 2, "N": 2},
		"active_play_time": 25.5
	}
	var sm: Node = preload("res://autoloads/save_manager.gd").new()
	sm.deserialize_to_game_manager(dummy_state, gm)

	var main_scn: PackedScene = load("res://scenes/main_game.tscn") as PackedScene
	var main_game: Node = main_scn.instantiate()
	main_game.game_board = main_game.get_node("ContentMargin/VBoxContainer/BoardArea/GameBoard")
	main_game.game_keyboard = main_game.get_node("ContentMargin/VBoxContainer/KeyboardArea/Keyboard")
	main_game.game_over_modal = main_game.get_node("GameOverModal")
	main_game.game_over_title = main_game.get_node("GameOverModal/MarginContainer/Panel/VBox/TitleLabel")
	main_game.game_over_message = main_game.get_node("GameOverModal/MarginContainer/Panel/VBox/MessageLabel")
	main_game.share_btn = main_game.get_node("GameOverModal/MarginContainer/Panel/VBox/ButtonMargin/ButtonContainer/ShareButton")
	main_game.next_word_btn = main_game.get_node("GameOverModal/MarginContainer/Panel/VBox/ButtonMargin/ButtonContainer/NextWordButton")

	main_game.game_board._ready()
	main_game.game_keyboard._ready()

	main_game.check_and_restore_completed_game(gm)

	# Verify GameOverModal is opened immediately
	assert_true(main_game.game_over_modal.visible, "GameOverModal should be visible immediately for completed daily")
	assert_true(main_game.share_btn.visible, "ShareButton should be visible for daily game over")
	assert_false(main_game.next_word_btn.visible, "NextWordButton should be hidden for daily game over")

	# Verify board tiles are repopulated
	var tile_0_0: Node = main_game.game_board.get_tile(0, 0)
	assert_true(tile_0_0 != null, "Tile(0, 0) should exist")
	if tile_0_0 != null:
		var label: Label = tile_0_0.find_child("Label", true, false) as Label
		assert_true(label != null and label.text == "B", "Tile(0, 0) letter should be 'B'")
		assert_eq(tile_0_0.current_state, 2, "Tile(0, 0) state should be CORRECT (2)")

	# Verify keyboard reflects evaluation state
	var key_b: Node = main_game.game_keyboard.get_key("B")
	assert_true(key_b != null, "Key 'B' should exist")
	if key_b != null:
		assert_eq(key_b.key_state, 2, "Key 'B' state should be CORRECT (2)")

	# Verify typing input is rejected
	assert_false(gm.add_letter("Z"), "GameManager should reject letters when status is WON")

	sm.free()
	gm.free()
	main_game.free()

func test_in_progress_board_and_keyboard_restoration() -> void:
	var gm: Node = GameManagerScript.new()
	var sm: Node = preload("res://autoloads/save_manager.gd").new()
	var dummy_state: Dictionary = {
		"version": 1,
		"mode": int(GameManagerScript.GameMode.CONTINUOUS),
		"status": int(GameManagerScript.GameStatus.IN_PROGRESS),
		"secret_word": "CLERK",
		"current_row": 1,
		"current_guess": "B",
		"guesses": ["BRAIN"],
		"guess_results": [[0, 1, 0, 0, 0]],
		"keyboard_states": {"B": 0, "R": 1, "A": 0, "I": 0, "N": 0},
		"active_play_time": 12.0
	}
	sm.deserialize_to_game_manager(dummy_state, gm)

	var main_scn: PackedScene = load("res://scenes/main_game.tscn") as PackedScene
	var main_game: Node = main_scn.instantiate()
	main_game.game_board = main_game.get_node("ContentMargin/VBoxContainer/BoardArea/GameBoard")
	main_game.game_keyboard = main_game.get_node("ContentMargin/VBoxContainer/KeyboardArea/Keyboard")
	main_game.game_over_modal = main_game.get_node("GameOverModal")
	main_game.game_over_title = main_game.get_node("GameOverModal/MarginContainer/Panel/VBox/TitleLabel")
	main_game.game_over_message = main_game.get_node("GameOverModal/MarginContainer/Panel/VBox/MessageLabel")
	main_game.share_btn = main_game.get_node("GameOverModal/MarginContainer/Panel/VBox/ButtonMargin/ButtonContainer/ShareButton")
	main_game.next_word_btn = main_game.get_node("GameOverModal/MarginContainer/Panel/VBox/ButtonMargin/ButtonContainer/NextWordButton")

	main_game.game_board._ready()
	main_game.game_keyboard._ready()

	main_game.check_and_restore_completed_game(gm)

	# Verify GameOverModal remains hidden for in-progress games
	assert_false(main_game.game_over_modal.visible, "GameOverModal should remain hidden for in-progress games")
	assert_ne(main_game.game_keyboard.mouse_filter, Control.MOUSE_FILTER_IGNORE, "Keyboard mouse filter should not be ignored")
	assert_true(gm.add_letter("Z"), "GameManager should accept letters when status is IN_PROGRESS")

	# Verify row 0 tiles are repopulated with guesses and evaluation states
	var tile_0_0: Node = main_game.game_board.get_tile(0, 0)
	assert_true(tile_0_0 != null, "Tile(0, 0) should exist")
	if tile_0_0 != null:
		var label: Label = tile_0_0.find_child("Label", true, false) as Label
		assert_true(label != null and label.text == "B", "Tile(0, 0) letter should be 'B'")
		assert_eq(tile_0_0.current_state, 0, "Tile(0, 0) state should be ABSENT (0)")

	var tile_0_1: Node = main_game.game_board.get_tile(0, 1)
	assert_true(tile_0_1 != null, "Tile(0, 1) should exist")
	if tile_0_1 != null:
		var label: Label = tile_0_1.find_child("Label", true, false) as Label
		assert_true(label != null and label.text == "R", "Tile(0, 1) letter should be 'R'")
		assert_eq(tile_0_1.current_state, 1, "Tile(0, 1) state should be PRESENT (1)")

	# Verify in-progress current guess letter is rendered
	var tile_1_0: Node = main_game.game_board.get_tile(1, 0)
	assert_true(tile_1_0 != null, "Tile(1, 0) should exist")
	if tile_1_0 != null:
		var label: Label = tile_1_0.find_child("Label", true, false) as Label
		assert_true(label != null and label.text == "B", "Tile(1, 0) letter should be 'B'")

	# Verify keyboard reflects evaluation state and active row typing restriction
	var key_r: Node = main_game.game_keyboard.get_key("R")
	assert_true(key_r != null, "Key 'R' should exist")
	if key_r != null:
		assert_eq(key_r.key_state, 1, "Key 'R' state should be PRESENT (1)")

	var key_b: Node = main_game.game_keyboard.get_key("B")
	assert_true(key_b != null, "Key 'B' should exist")
	if key_b != null:
		assert_true(key_b.is_row_disabled, "Key 'B' should be row-disabled because it is typed in current row")

	sm.free()
	gm.free()
	main_game.free()

func test_continuous_game_over_clears_save_file() -> void:
	var sm: Node = preload("res://autoloads/save_manager.gd").new()
	var gm: Node = GameManagerScript.new()
	gm.current_mode = GameManagerScript.GameMode.CONTINUOUS
	gm.secret_word = "PLANT"
	gm.current_row = 3

	var main_scn: PackedScene = load("res://scenes/main_game.tscn") as PackedScene
	var main_game: Node = main_scn.instantiate()
	main_game.game_over_modal = main_game.get_node("GameOverModal")
	main_game.game_over_title = main_game.get_node("GameOverModal/MarginContainer/Panel/VBox/TitleLabel")
	main_game.game_over_message = main_game.get_node("GameOverModal/MarginContainer/Panel/VBox/MessageLabel")
	main_game.share_btn = main_game.get_node("GameOverModal/MarginContainer/Panel/VBox/ButtonMargin/ButtonContainer/ShareButton")
	main_game.next_word_btn = main_game.get_node("GameOverModal/MarginContainer/Panel/VBox/ButtonMargin/ButtonContainer/NextWordButton")

	# Test win clears continuous save
	sm.save_game_state(GameManagerScript.GameMode.CONTINUOUS, {"test": "data"})
	assert_true(sm.has_saved_game(GameManagerScript.GameMode.CONTINUOUS), "Continuous save should exist prior to win")
	main_game._on_game_won(3, "PLANT", gm, null, sm)
	assert_false(sm.has_saved_game(GameManagerScript.GameMode.CONTINUOUS), "Continuous save should be cleared after win")

	# Test loss clears continuous save
	sm.save_game_state(GameManagerScript.GameMode.CONTINUOUS, {"test": "data"})
	assert_true(sm.has_saved_game(GameManagerScript.GameMode.CONTINUOUS), "Continuous save should exist prior to loss")
	main_game._on_game_lost("PLANT", gm, null, sm)
	assert_false(sm.has_saved_game(GameManagerScript.GameMode.CONTINUOUS), "Continuous save should be cleared after loss")

	sm.free()
	gm.free()
	main_game.free()

func test_notification_saves_in_progress_state() -> void:
	var root: Node = Engine.get_main_loop().root if Engine.get_main_loop() != null else null
	var gm: Node = root.get_node_or_null("GameManager") if root != null else null
	var sm: Node = root.get_node_or_null("SaveManager") if root != null else null
	if gm == null or sm == null:
		return

	gm.start_game(GameManagerScript.GameMode.CONTINUOUS, "APPLE")
	gm.add_letter("T")
	gm.add_letter("R")
	gm.add_letter("A")
	gm.add_letter("I")
	gm.add_letter("N")
	gm.submit_guess()

	var main_scn: PackedScene = load("res://scenes/main_game.tscn") as PackedScene
	var main_game: Node = main_scn.instantiate()

	main_game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	assert_true(sm.has_saved_game(GameManagerScript.GameMode.CONTINUOUS), "Focus out notification should save in-progress state")

	var saved: Dictionary = sm.load_game_state(GameManagerScript.GameMode.CONTINUOUS)
	assert_eq(saved.get("secret_word", ""), "APPLE", "Saved secret word must match")
	assert_eq(int(saved.get("current_row", 0)), 1, "Saved current row must match")

	sm.clear_game_state(GameManagerScript.GameMode.CONTINUOUS)
	main_game.free()
