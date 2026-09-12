# tests/test_main_game.gd
extends "res://tests/test_base.gd"

## Automated unit tests for MainGame scene.

func test_toast_overlay_position() -> void:
	var main_scn: PackedScene = load("res://scenes/main_game.tscn") as PackedScene
	assert_true(main_scn != null, "main_game.tscn must be loadable")
	
	var main_game: Node = main_scn.instantiate()
	assert_true(main_game != null, "main_game must instantiate successfully")
	
	var vbox: VBoxContainer = main_game.get_node_or_null("VBoxContainer") as VBoxContainer
	assert_true(vbox != null, "VBoxContainer should exist in MainGame")
	
	var toast_overlay: Control = vbox.get_node_or_null("ToastOverlay") as Control
	assert_true(toast_overlay != null, "ToastOverlay should be a native child of VBoxContainer")
	
	var header: Control = vbox.get_node_or_null("Header") as Control
	var board_area: Control = vbox.get_node_or_null("BoardArea") as Control
	assert_true(header != null, "Header should exist in VBoxContainer")
	assert_true(board_area != null, "BoardArea should exist in VBoxContainer")
	
	# Verify that ToastOverlay is mathematically constrained between Header and BoardArea
	assert_true(toast_overlay.get_index() > header.get_index(), "ToastOverlay must be positioned after Header")
	assert_true(toast_overlay.get_index() < board_area.get_index(), "ToastOverlay must be positioned before BoardArea")
	
	# Verify ToastOverlay is a CenterContainer with layout_mode 2 (Container child) without hardcoded absolute offsets
	assert_true(toast_overlay is CenterContainer, "ToastOverlay should be a CenterContainer")
	assert_eq(toast_overlay.layout_mode, 2, "ToastOverlay should use layout_mode 2 (Container child)")
	
	# Verify toast panel, label, and timer nodes exist
	var toast_panel: PanelContainer = toast_overlay.get_node_or_null("ToastPanel") as PanelContainer
	assert_true(toast_panel != null, "ToastPanel should exist in ToastOverlay")
	var toast_label: Label = toast_overlay.get_node_or_null("ToastPanel/ToastLabel") as Label
	var toast_timer: Timer = toast_overlay.get_node_or_null("ToastTimer") as Timer
	assert_true(toast_label != null, "ToastLabel should exist inside ToastPanel")
	assert_true(toast_timer != null, "ToastTimer should exist inside ToastOverlay")
	
	# Verify toast visibility toggling
	main_game._ready()
	assert_false(toast_overlay.visible, "ToastOverlay should be hidden on initial ready")
	
	main_game.call("show_toast", "Test Toast")
	assert_true(toast_overlay.visible, "ToastOverlay should become visible when show_toast is called")
	assert_eq(toast_label.text, "Test Toast", "ToastLabel text should match message")
	
	main_game.call("_on_toast_timer_timeout")
	assert_false(toast_overlay.visible, "ToastOverlay should hide on timer timeout")
	
	main_game.free()
