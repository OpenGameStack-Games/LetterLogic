# tests/test_main_menu.gd
extends "res://tests/test_base.gd"

## Automated unit tests for MainMenu and navigation scenes.

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
	
	var daily_btn: Button = menu.find_child("DailyButton", true, false) as Button
	var cont_btn: Button = menu.find_child("ContinuousButton", true, false) as Button
	var stats_btn: Button = menu.find_child("StatsButton", true, false) as Button
	var htp_btn: Button = menu.find_child("HowToPlayButton", true, false) as Button
	
	assert_true(daily_btn != null, "DailyButton should exist")
	assert_true(cont_btn != null, "ContinuousButton should exist")
	assert_true(stats_btn != null, "StatsButton should exist")
	assert_true(htp_btn != null, "HowToPlayButton should exist")
	
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
	
	var mode_lbl: Label = main_game.get_node_or_null("VBoxContainer/Header/TitleBox/ModeLabel") as Label
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
	menu.set("mascot_rect", mascot)
	if mascot != null and menu.has_method("_start_mascot_animation"):
		menu.call("_start_mascot_animation")
	
	assert_true(mascot != null, "MascotRect should exist in MainMenu")
	
	if mascot != null:
		assert_true(mascot.texture != null, "MascotRect should have a texture assigned")
		var expected_path: String = "res://assets/icons/icon.png"
		if mascot.texture != null:
			assert_eq(mascot.texture.resource_path, expected_path, "MascotRect should use the icon.png texture")
	
	# Verify that the animation is running (tween exists)
	var menu_script_inst: Node = menu
	assert_true(menu_script_inst.get("_mascot_tween") != null, "Mascot breathing tween should be created")
	if menu_script_inst.get("_mascot_tween") != null:
		assert_true(menu_script_inst.get("_mascot_tween").is_running(), "Mascot breathing tween should be running")
	
	menu.queue_free()

