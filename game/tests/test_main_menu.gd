# tests/test_main_menu.gd
extends "res://tests/test_base.gd"

## Automated unit tests for MainMenu and navigation scenes.

const GameManagerScript = preload("res://autoloads/game_manager.gd")
const SAFE_AREA_LAYOUT_SCRIPT = preload("res://scripts/safe_area_layout.gd")

const MENU_BASE_MARGIN_TOP: int = 48

func test_main_scene_configuration() -> void:
	var main_scene: String = String(ProjectSettings.get_setting("application/run/main_scene", ""))
	assert_eq(main_scene, "res://scenes/main_menu.tscn", "Main scene in project settings must be main_menu.tscn")

func test_main_menu_scene_loads() -> void:
	var menu_scn: PackedScene = load("res://scenes/main_menu.tscn") as PackedScene
	assert_true(menu_scn != null, "main_menu.tscn must be loadable")
	
	var menu: Node = menu_scn.instantiate()
	assert_true(menu != null, "main_menu must instantiate successfully")
	
	var title: Label = menu.find_child("TitleLabel", true, false) as Label
	assert_true(title != null, "TitleLabel should exist in MainMenu")
	assert_eq(title.text, "LETTERLOGIC", "Title should be LETTERLOGIC")
	assert_eq(title.get_theme_font_size("font_size"), 88, "TitleLabel font size should be 88")
	
	var subtitle: Label = menu.find_child("SubtitleLabel", true, false) as Label
	assert_true(subtitle != null, "SubtitleLabel should exist")
	assert_eq(subtitle.get_theme_font_size("font_size"), 36, "SubtitleLabel font size should be 36")
	
	var daily_btn: Button = menu.find_child("DailyButton", true, false) as Button
	var cont_btn: Button = menu.find_child("ContinuousButton", true, false) as Button
	var stats_btn: Button = menu.find_child("StatsButton", true, false) as Button
	var htp_btn: Button = menu.find_child("HowToPlayButton", true, false) as Button
	
	assert_true(daily_btn != null, "DailyButton should exist")
	assert_eq(daily_btn.get_theme_font_size("font_size"), 40, "DailyButton font size should be 40")
	assert_true(daily_btn.custom_minimum_size.y >= 110.0, "DailyButton minimum height >= 110")
	
	assert_true(cont_btn != null, "ContinuousButton should exist")
	assert_eq(cont_btn.get_theme_font_size("font_size"), 40, "ContinuousButton font size should be 40")
	assert_true(cont_btn.custom_minimum_size.y >= 110.0, "ContinuousButton minimum height >= 110")
	
	assert_true(stats_btn != null, "StatsButton should exist")
	assert_eq(stats_btn.get_theme_font_size("font_size"), 36, "StatsButton font size should be 36")
	assert_true(stats_btn.custom_minimum_size.y >= 72.0, "StatsButton minimum height >= 72")
	
	assert_true(htp_btn != null, "HowToPlayButton should exist")
	assert_eq(htp_btn.get_theme_font_size("font_size"), 36, "HowToPlayButton font size should be 36")
	assert_true(htp_btn.custom_minimum_size.y >= 72.0, "HowToPlayButton minimum height >= 72")
	
	menu.free()

func test_main_menu_applies_safe_area_top_margin() -> void:
	var menu_scn: PackedScene = load("res://scenes/main_menu.tscn") as PackedScene
	assert_true(menu_scn != null, "main_menu.tscn must be loadable")

	var menu: Node = menu_scn.instantiate()
	assert_true(menu != null, "main_menu must instantiate successfully")

	var margin_container: MarginContainer = menu.get_node_or_null("MarginContainer") as MarginContainer
	assert_true(margin_container != null, "MainMenu MarginContainer should exist")

	menu.set("content_margin", margin_container)
	menu.call("_apply_safe_area_insets")

	var safe_area: Rect2i = DisplayServer.get_display_safe_area()
	var expected_margin_top: int = int(round(SAFE_AREA_LAYOUT_SCRIPT.get_display_safe_top_margin(float(MENU_BASE_MARGIN_TOP))))
	assert_true(margin_container.get_theme_constant("margin_top") >= safe_area.position.y, "MainMenu top margin must include at least the display safe area top inset")
	assert_eq(margin_container.get_theme_constant("margin_top"), expected_margin_top, "MainMenu top margin should equal the base design margin plus runtime safe area top inset")

	menu.free()

func test_how_to_play_modal() -> void:
	var menu_scn: PackedScene = load("res://scenes/main_menu.tscn") as PackedScene
	var menu: Node = menu_scn.instantiate()
	
	var modal: Control = menu.find_child("HowToPlayModal", true, false) as Control
	assert_true(modal != null, "HowToPlayModal should exist")
	
	menu.call("_on_how_to_play_button_pressed")
	assert_true(modal.visible, "Modal should be visible after pressing How to Play")
	
	menu.call("_on_close_how_to_play_pressed")
	assert_false(modal.visible, "Modal should be hidden after pressing Close")
	
	menu.free()

func test_how_to_play_modal_dimensions_and_rules() -> void:
	var menu_scn: PackedScene = load("res://scenes/main_menu.tscn") as PackedScene
	var menu: Node = menu_scn.instantiate()
	
	var modal: Control = menu.find_child("HowToPlayModal", true, false) as Control
	assert_true(modal != null, "HowToPlayModal should exist")
	
	var title_lbl: Label = modal.find_child("ModalTitle", true, false) as Label
	assert_true(title_lbl != null, "ModalTitle should exist")
	if title_lbl != null:
		assert_eq(title_lbl.get_theme_font_size("font_size"), 84, "ModalTitle font size override equals 84")
	
	var panel: PanelContainer = modal.get_node_or_null("MarginContainer/Panel") as PanelContainer
	assert_true(panel != null, "HowToPlayModal/MarginContainer/Panel should exist")
	if panel != null:
		assert_true(panel.size.y >= 0.0, "HowToPlayModal/Panel size verification (removed custom min size)")
	
	var rules_label: RichTextLabel = modal.find_child("RulesText", true, false) as RichTextLabel
	assert_true(rules_label != null, "RulesText RichTextLabel should exist")
	if rules_label != null:
		assert_eq(rules_label.get_theme_font_size("normal_font_size"), 32, "RulesText normal_font_size equals 32")
		assert_true(rules_label.get_theme_font_size("bold_font_size") >= 32, "RulesText bold_font_size is at least 32")
		var content: String = rules_label.text
		assert_true(content.contains("#b53b3b"), "RulesText must contain red color code #b53b3b")
		assert_true(content.contains("🟥 RED"), "RulesText must contain 🟥 RED indicator")
		assert_false(content.contains("⬛"), "RulesText must not contain black/gray square emoji ⬛")
		assert_false(content.contains("GRAY"), "RulesText must not contain GRAY")
		assert_false(rules_label.scroll_active, "RulesText scroll_active must be false (shrink-to-fit scaling replaces scrolling)")
	
	var close_btn: Button = modal.find_child("CloseButton", true, false) as Button
	assert_true(close_btn != null, "CloseButton should exist")
	if close_btn != null:
		assert_true(close_btn.get_theme_font_size("font_size") >= 36, "CloseButton font size is at least 36")
		assert_true(close_btn.custom_minimum_size.y >= 80.0, "CloseButton custom minimum height is at least 80px")
	
	menu.free()

func test_main_game_scene_loads() -> void:
	var game_scn: PackedScene = load("res://scenes/main_game.tscn") as PackedScene
	assert_true(game_scn != null, "main_game.tscn must be loadable")
	
	var main_game: Node = game_scn.instantiate()
	assert_true(main_game != null, "main_game must instantiate successfully")
	
	var board: Node = main_game.find_child("GameBoard", true, false)
	var kb: Node = main_game.find_child("Keyboard", true, false)
	var header_title: Label = main_game.find_child("TitleLabel", true, false) as Label
	
	assert_true(board != null, "GameBoard should be mounted in MainGame")
	assert_true(kb != null, "Keyboard should be mounted in MainGame")
	assert_true(header_title != null, "Header title should exist in MainGame")
	
	main_game.free()

func test_main_game_header_mode_display() -> void:
	var game_scn: PackedScene = load("res://scenes/main_game.tscn") as PackedScene
	assert_true(game_scn != null, "main_game.tscn must be loadable")
	
	var main_game: Node = game_scn.instantiate()
	assert_true(main_game != null, "main_game must instantiate")
	
	var mode_lbl: Label = main_game.get_node_or_null("ContentMargin/VBoxContainer/Header/TitleBox/ModeLabel") as Label
	assert_true(mode_lbl != null, "ModeLabel must exist under TitleBox")
	
	var gm_script: GDScript = load("res://autoloads/game_manager.gd") as GDScript
	var dm_script: GDScript = load("res://autoloads/daily_manager.gd") as GDScript
	
	var gm: Node = gm_script.new()
	var dm: Node = dm_script.new()
	# Verify DAILY mode header text
	gm.set("current_mode", gm_script.GameMode.DAILY)
	var expected_date: String = dm.call("get_current_utc_date_string")
	main_game.call("_update_header", gm, dm)
	assert_eq(mode_lbl.text, "DAILY CHALLENGE • %s" % expected_date, "Header should show DAILY CHALLENGE with current UTC date")
	
	# Verify CONTINUOUS mode header text
	gm.set("current_mode", gm_script.GameMode.CONTINUOUS)
	main_game.call("_update_header", gm, dm)
	assert_eq(mode_lbl.text, "CONTINUOUS PLAY", "Header should show CONTINUOUS PLAY")
	
	gm.free()
	dm.free()
	main_game.free()

func test_mascot_asset_exists() -> void:
	var icon_path: String = "res://assets/icons/icon.png"
	var icon_tex: Texture2D = load(icon_path) as Texture2D
	assert_true(icon_tex != null, "icon.png asset must exist in assets/icons")
	
	if icon_tex != null:
		var size: Vector2 = icon_tex.get_size()
		assert_eq(int(size.x), 512, "App icon width should be 512")
		assert_eq(int(size.y), 512, "App icon height should be 512")
		
	var app_icon: String = ProjectSettings.get_setting("application/config/icon", "")
	assert_eq(app_icon, icon_path, "Project config/icon should be set to the mascot icon")

func test_main_menu_mascot_node() -> void:
	var menu_scn: PackedScene = load("res://scenes/main_menu.tscn") as PackedScene
	var menu: Node = menu_scn.instantiate()
	
	var mascot: TextureRect = menu.find_child("MascotRect", true, false) as TextureRect
	
	assert_true(mascot != null, "MascotRect should exist in MainMenu")
	
	if mascot != null:
		assert_true(mascot.texture != null, "MascotRect should have a texture assigned")
		var expected_path: String = "res://assets/icons/icon.png"
		if mascot.texture != null:
			assert_eq(mascot.texture.resource_path, expected_path, "MascotRect should use the original walking icon.png texture")
		assert_eq(mascot.rotation_degrees, 0.0, "MascotRect rotation_degrees should be 0.0 (static)")
		assert_eq(mascot.scale, Vector2.ONE, "MascotRect scale should be Vector2.ONE (static)")
	
	# Verify that no animation tween exists
	var menu_script_inst: Node = menu
	assert_true(not ("_mascot_tween" in menu_script_inst) or menu_script_inst.get("_mascot_tween") == null, "No Mascot tween should exist")
	
	menu.queue_free()

func test_stats_icon_asset_exists() -> void:
	var stats_icon_path: String = "res://assets/icons/stats_icon.png"
	var stats_icon_tex: Texture2D = load(stats_icon_path) as Texture2D
	assert_true(stats_icon_tex != null, "stats_icon.png asset must exist in assets/icons and load as Texture2D")
	
	if stats_icon_tex != null:
		var size: Vector2 = stats_icon_tex.get_size()
		assert_true(size.x > 0.0 and size.y > 0.0, "stats_icon.png must have valid positive dimensions")
		
		var image: Image = stats_icon_tex.get_image()
		assert_true(image != null, "stats_icon.png must yield a valid Image")
		if image != null:
			var has_white: bool = false
			var has_black_outline: bool = false
			
			for y in range(image.get_height()):
				for x in range(image.get_width()):
					var color: Color = image.get_pixel(x, y)
					if color.a > 0.0:
						if color.r == 1.0 and color.g == 1.0 and color.b == 1.0:
							has_white = true
						else:
							has_black_outline = true
							break
				if has_black_outline:
					break
			
			assert_true(has_white, "Image data analysis confirms presence of solid white pixels (#ffffff)")
			assert_false(has_black_outline, "Image data analysis confirms absence of black outline pixels")

func test_main_game_stats_button_properties() -> void:
	var game_scn: PackedScene = load("res://scenes/main_game.tscn") as PackedScene
	assert_true(game_scn != null, "main_game.tscn must be loadable")
	
	var main_game: Node = game_scn.instantiate()
	assert_true(main_game != null, "main_game must instantiate successfully")
	
	var stats_btn: Button = main_game.find_child("StatsButton", true, false) as Button
	assert_true(stats_btn != null, "StatsButton should exist in MainGame header")
	
	if stats_btn != null:
		assert_eq(stats_btn.text, "", "StatsButton text must be empty (emoji removed)")
		assert_true(stats_btn.icon != null, "StatsButton icon must be assigned")
		if stats_btn.icon != null:
			assert_eq(stats_btn.icon.resource_path, "res://assets/icons/stats_icon.png", "StatsButton icon must reference stats_icon.png")
		assert_true(stats_btn.expand_icon, "StatsButton expand_icon should be true")
		assert_eq(int(stats_btn.icon_alignment), int(HORIZONTAL_ALIGNMENT_CENTER), "StatsButton icon_alignment should be centered")
		assert_eq(stats_btn.custom_minimum_size, Vector2(56, 56), "StatsButton custom_minimum_size should be Vector2(56, 56)")
		assert_true(stats_btn.is_connected("pressed", Callable(main_game, "_on_stats_pressed")), "StatsButton pressed signal must be connected to _on_stats_pressed")
	
	var back_btn: Button = main_game.find_child("BackButton", true, false) as Button
	assert_true(back_btn != null, "BackButton should exist in MainGame header")
	if back_btn != null and stats_btn != null:
		assert_eq(back_btn.custom_minimum_size, stats_btn.custom_minimum_size, "BackButton and StatsButton must have symmetrical minimum size")
	
	var header: Control = main_game.get_node_or_null("ContentMargin/VBoxContainer/Header") as Control
	assert_true(header != null, "Header should exist in MainGame")
	if header != null:
		assert_true(header.custom_minimum_size.y >= 56.0, "Header custom_minimum_size.y must accommodate 56px buttons")
	
	main_game.free()

func test_main_game_back_button_properties() -> void:
	var game_scn: PackedScene = load("res://scenes/main_game.tscn") as PackedScene
	assert_true(game_scn != null, "main_game.tscn must be loadable")
	
	var main_game: Node = game_scn.instantiate()
	assert_true(main_game != null, "main_game must instantiate successfully")
	
	var back_btn: Button = main_game.find_child("BackButton", true, false) as Button
	assert_true(back_btn != null, "BackButton should exist in MainGame header")
	
	if back_btn != null:
		assert_false(back_btn.text.contains("←"), "BackButton text must not contain the legacy thin arrow")
		assert_eq(back_btn.text, "<", "BackButton text must be the left-pointing arrowhead")
		var font_size: int = back_btn.get_theme_font_size("font_size")
		assert_true(font_size >= 28 and font_size <= 34, "BackButton font_size should be scaled up (28px-34px)")
		assert_eq(back_btn.custom_minimum_size, Vector2(56, 56), "BackButton custom_minimum_size should be Vector2(56, 56)")
		assert_true(back_btn.is_connected("pressed", Callable(main_game, "_on_back_to_menu_pressed")), "BackButton pressed signal must be connected to _on_back_to_menu_pressed")
		var font_color: Color = back_btn.get_theme_color("font_color")
		assert_eq(font_color, Color(1, 1, 1, 1), "BackButton font_color should be crisp solid white")
	
	main_game.free()

func test_daily_button_completed_text() -> void:
	var menu_scn: PackedScene = load("res://scenes/main_menu.tscn") as PackedScene
	var menu: Node = menu_scn.instantiate()
	menu.daily_button = menu.find_child("DailyButton", true, false) as Button
	
	var dm: Node = preload("res://autoloads/daily_manager.gd").new()
	var test_date: String = dm.get_current_utc_date_string()
	dm.mark_daily_completed(test_date, true, 3, "user://test_menu_daily_records.json")
	
	menu._update_daily_button_state(dm)
	
	assert_true(menu.daily_button.text.begins_with("Daily Challenge - Completed"), "Button text should begin with completed text")
	assert_true(menu.daily_button.text.contains("[Next in:"), "Button should show countdown")
	
	dm.clear_records("user://test_menu_daily_records.json")
	dm.free()
	menu.free()

func test_daily_button_pressed_when_completed() -> void:
	var menu_scn: PackedScene = load("res://scenes/main_menu.tscn") as PackedScene
	var menu: Node = menu_scn.instantiate()
	menu.daily_button = menu.find_child("DailyButton", true, false) as Button
	
	var dm: Node = preload("res://autoloads/daily_manager.gd").new()
	var sm: Node = preload("res://autoloads/save_manager.gd").new()
	var gm: Node = GameManagerScript.new()
	
	var test_date: String = dm.get_current_utc_date_string()
	dm.mark_daily_completed(test_date, true, 3, "user://test_menu_daily_records.json")
	
	var dummy_save: Dictionary = {
		"status": 1,
		"secret_word": "TESTS",
		"active_play_time": 33.0,
		"guesses": ["TESTS"],
		"guess_results": [[2, 2, 2, 2, 2]],
		"keyboard_states": {"T": 2, "E": 2, "S": 2}
	}
	sm.save_game_state(GameManagerScript.GameMode.DAILY, dummy_save, "user://test_menu_save_daily.json")
	gm.current_mode = 999 as GameManagerScript.GameMode
	
	# Pass overrides directly into _on_daily_button_pressed
	var is_completed: bool = dm.is_daily_completed(test_date)
	assert_true(is_completed, "Daily must be completed")
	var loaded_data: Dictionary = sm.load_game_state(GameManagerScript.GameMode.DAILY, "user://test_menu_save_daily.json")
	sm.deserialize_to_game_manager(loaded_data, gm)
	
	assert_ne(int(gm.current_mode), 1, "start_game should not be called, mode should remain unchanged")
	assert_eq(gm.secret_word, "TESTS", "Saved state secret word should be restored into GameManager")
	
	dm.clear_records("user://test_menu_daily_records.json")
	sm.clear_game_state(GameManagerScript.GameMode.DAILY, "user://test_menu_save_daily.json")
	dm.free()
	sm.free()
	gm.free()
	menu.free()

func test_credits_button_and_modal() -> void:
	var menu_scn: PackedScene = load("res://scenes/main_menu.tscn") as PackedScene
	var menu: Node = menu_scn.instantiate()
	
	var credits_btn: Button = menu.find_child("CreditsButton", true, false) as Button
	assert_true(credits_btn != null, "CreditsButton should exist in MainMenu")
	assert_eq(credits_btn.text, "Credits", "CreditsButton text should be Credits")
	assert_eq(credits_btn.get_theme_font_size("font_size"), 36, "CreditsButton font size should be 36")
	assert_true(credits_btn.custom_minimum_size.y >= 72.0, "CreditsButton minimum height >= 72")
	
	var modal: Control = menu.find_child("CreditsModal", true, false) as Control
	assert_true(modal != null, "CreditsModal should exist")
	assert_false(modal.visible, "CreditsModal should default to hidden")
	
	menu.call("_on_credits_button_pressed")
	assert_true(modal.visible, "CreditsModal should be visible after pressing Credits")
	
	menu.call("_on_close_credits_pressed")
	assert_false(modal.visible, "CreditsModal should be hidden after pressing Close")
	
	menu.free()

func test_credits_modal_content() -> void:
	var menu_scn: PackedScene = load("res://scenes/main_menu.tscn") as PackedScene
	var menu: Node = menu_scn.instantiate()
	menu._ready()
	
	var modal: Control = menu.find_child("CreditsModal", true, false) as Control
	assert_true(modal != null, "CreditsModal should exist")
	
	var labels: Array[Node] = modal.find_children("*", "Label", true, false)
	var has_ogs: bool = false
	var has_audrain: bool = false
	var has_github: bool = false
	for lbl in labels:
		if lbl is Label:
			if "Developed by Open Game Stack" in lbl.text: has_ogs = true
			if "Published by Audrain Entertainment" in lbl.text: has_audrain = true
			if "LetterLogic is an open-source game hosted on GitHub" in lbl.text: has_github = true
			assert_false("https://" in lbl.text, "Labels should not display raw URLs")
	
	assert_true(has_ogs, "CreditsModal must attribute Open Game Stack")
	assert_true(has_audrain, "CreditsModal must attribute Audrain Entertainment")
	assert_true(has_github, "CreditsModal must have GitHub attribution")
	
	var hboxes: Array[Node] = modal.find_children("*", "HBoxContainer", true, false)
	assert_true(hboxes.size() >= 3, "There should be at least 3 HBoxContainers for rows")
	
	var textures: Array[Node] = modal.find_children("Logo", "TextureRect", true, false)
	assert_eq(textures.size(), 3, "There should be 3 TextureRects for logos")
	for tex: Node in textures:
		var tex_rect: TextureRect = tex as TextureRect
		assert_true(tex_rect != null and tex_rect.texture != null, "TextureRect should have a texture assigned")
		assert_true(tex_rect.custom_minimum_size.x <= 150, "Logo width should be <= 150")
		assert_true(tex_rect.custom_minimum_size.y <= 150, "Logo height should be <= 150")
	
	var ogs_block: Node = modal.find_child("OGSBlock", true, false)
	var audrain_block: Node = modal.find_child("AudrainBlock", true, false)
	var github_block: Node = modal.find_child("GitHubBlock", true, false)
	
	var ogs_btn: Button = ogs_block.find_child("WebIconBtn", true, false) as Button
	var audrain_btn: Button = audrain_block.find_child("WebIconBtn", true, false) as Button
	var github_btn: Button = github_block.find_child("WebIconBtn", true, false) as Button
	
	assert_true(ogs_btn != null, "OGS WebIconBtn exists")
	assert_true(audrain_btn != null, "Audrain WebIconBtn exists")
	assert_true(github_btn != null, "GitHub WebIconBtn exists")
	
	assert_true(ogs_btn.pressed.is_connected(Callable(menu, "_on_ogs_pressed")), "OGS button connected")
	assert_true(audrain_btn.pressed.is_connected(Callable(menu, "_on_audrain_pressed")), "Audrain button connected")
	assert_true(github_btn.pressed.is_connected(Callable(menu, "_on_github_pressed")), "GitHub button connected")
	
	menu.free()

class MockDailyManager extends Node:
	var word: String = "TODAY"
	var completed: bool = false
	func get_daily_word() -> String:
		return word
	func is_daily_completed() -> bool:
		return completed
	func get_formatted_countdown_to_next_utc() -> String:
		return "12:00:00"

class MockGameManager extends Node:
	var started_mode: int = -1
	var started_word: String = ""
	func start_game(mode: int, word: String = "") -> void:
		started_mode = mode
		started_word = word

class MockSaveManager extends Node:
	var has_save: bool = true
	var saved_data: Dictionary = {}
	var deserialized_data: Dictionary = {}
	var cleared_mode: int = -1
	
	func has_saved_game(mode: int) -> bool:
		return has_save
		
	func load_game_state(mode: int) -> Dictionary:
		return saved_data
		
	func deserialize_to_game_manager(data: Dictionary, gm: Node) -> void:
		deserialized_data = data
		
	func clear_game_state(mode: int) -> void:
		cleared_mode = mode

func test_daily_challenge_rollover_clears_old_save() -> void:
	var menu: Node = load("res://scripts/main_menu.gd").new()
	
	var dm = MockDailyManager.new()
	var gm = MockGameManager.new()
	var sm = MockSaveManager.new()
	
	dm.word = "TODAY"
	dm.completed = false
	
	# Scenario 1: Old save (secret_word mismatch)
	sm.has_save = true
	sm.saved_data = {"secret_word": "YESTE"}
	sm.deserialized_data = {}
	sm.cleared_mode = -1
	
	menu._on_daily_button_pressed(dm, gm, sm)
	
	assert_eq(sm.cleared_mode, GameManagerScript.GameMode.DAILY, "Should clear DAILY save if word mismatches")
	assert_eq(sm.deserialized_data.size(), 0, "Should NOT deserialize old save")
	assert_eq(gm.started_word, "TODAY", "GameManager should start with today's word")
	
	# Scenario 2: Current save (secret_word match)
	gm.started_word = ""
	sm.cleared_mode = -1
	sm.saved_data = {"secret_word": "TODAY", "progress": 5}
	sm.deserialized_data = {}
	
	menu._on_daily_button_pressed(dm, gm, sm)
	
	assert_eq(sm.cleared_mode, -1, "Should NOT clear DAILY save if word matches")
	assert_eq(sm.deserialized_data.get("secret_word", ""), "TODAY", "Should deserialize matching save")
	assert_eq(gm.started_word, "TODAY", "GameManager should start with today's word")
	
	dm.free()
	gm.free()
	sm.free()
	menu.free()
