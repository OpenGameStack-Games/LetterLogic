# tests/test_main_game.gd
extends "res://tests/test_base.gd"

## Automated unit tests for MainGame scene.

func test_toast_overlay_position() -> void:
	var main_scn: PackedScene = load("res://scenes/main_game.tscn") as PackedScene
	assert_true(main_scn != null, "main_game.tscn must be loadable")
	
	var main_game: Node = main_scn.instantiate()
	assert_true(main_game != null, "main_game must instantiate successfully")
	
	var toast_overlay: Control = main_game.find_child("ToastOverlay", true, false) as Control
	assert_true(toast_overlay != null, "ToastOverlay should exist in MainGame")
	
	# The offset top should be 120.0 and bottom 180.0
	assert_eq(toast_overlay.offset_top, 120.0, "ToastOverlay offset_top should be 120.0 to avoid overlapping timer")
	assert_eq(toast_overlay.offset_bottom, 180.0, "ToastOverlay offset_bottom should be 180.0")
	
	main_game.free()

