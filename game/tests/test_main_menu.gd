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
