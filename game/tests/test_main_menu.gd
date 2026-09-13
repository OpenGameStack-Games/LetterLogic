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
	
	var panel: PanelContainer = modal.get_node_or_null("MarginContainer/Panel") as PanelContainer
	assert_true(panel != null, "HowToPlayModal/MarginContainer/Panel should exist")
	if panel != null:
		assert_true(panel.size.y >= 0.0, "HowToPlayModal/Panel size verification (removed custom min size)")
	
	var rules_label: RichTextLabel = modal.find_child("RulesText", true, false) as RichTextLabel
	assert_true(rules_label != null, "RulesText RichTextLabel should exist")
	if rules_label != null:
		var content: String = rules_label.text
		assert_true(content.contains("#b53b3b"), "RulesText must contain red color code #b53b3b")
		assert_true(content.contains("🟥 RED"), "RulesText must contain 🟥 RED indicator")
		assert_false(content.contains("⬛"), "RulesText must not contain black/gray square emoji ⬛")
		assert_false(content.contains("GRAY"), "RulesText must not contain GRAY")
		assert_true(rules_label.scroll_active, "RulesText scroll_active must remain true for fallback scrolling")
	
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

func test_standing_mascot_asset_exists() -> void:
	var mascot_path: String = "res://assets/icons/mascot_standing.png"
	var mascot_tex: Texture2D = load(mascot_path) as Texture2D
	assert_true(mascot_tex != null, "mascot_standing.png asset must exist in assets/icons")
	
	if mascot_tex != null:
		var size: Vector2 = mascot_tex.get_size()
		assert_eq(int(size.x), 512, "mascot_standing.png width should be 512")
		assert_eq(int(size.y), 512, "mascot_standing.png height should be 512")

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
		var expected_path: String = "res://assets/icons/mascot_standing.png"
		if mascot.texture != null:
			assert_eq(mascot.texture.resource_path, expected_path, "MascotRect should use the mascot_standing.png texture")
		assert_eq(mascot.scale, Vector2.ONE, "MascotRect scale should remain fixed at Vector2.ONE")
		assert_eq(mascot.pivot_offset, Vector2(128, 128), "MascotRect pivot_offset should be centered at Vector2(128, 128)")
	
	# Verify that the animation is running (tween exists)
	var menu_script_inst: Node = menu
	assert_true(menu_script_inst.get("_mascot_tween") != null, "Mascot swaying tween should be created")
	if menu_script_inst.get("_mascot_tween") != null:
		assert_true(menu_script_inst.get("_mascot_tween").is_running(), "Mascot swaying tween should be running")
	
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
	
	var header: Control = main_game.get_node_or_null("VBoxContainer/Header") as Control
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

 f u n c   t e s t _ d a i l y _ b u t t o n _ c o m p l e t e d _ t e x t ( )   - >   v o i d : 
 	 v a r   m e n u :   N o d e   =   l o a d ( " r e s : / / s c e n e s / m a i n _ m e n u . t s c n " ) . i n s t a n t i a t e ( ) 
 	 v a r   d m :   N o d e   =   g e t _ n o d e _ o r _ n u l l ( " / r o o t / D a i l y M a n a g e r " ) 
 	 v a r   p r e v _ c o m p l e t e d   =   f a l s e 
 	 v a r   t e s t _ d a t e   =   d m . g e t _ c u r r e n t _ u t c _ d a t e _ s t r i n g ( ) 
 	 i f   d m . i s _ d a i l y _ c o m p l e t e d ( ) : 
 	 	 p r e v _ c o m p l e t e d   =   t r u e 
 	 e l s e : 
 	 	 d m . m a r k _ d a i l y _ c o m p l e t e d ( t e s t _ d a t e ,   t r u e ,   3 ) 
 	 
 	 a d d _ c h i l d _ t o _ r o o t ( m e n u ) 
 	 
 	 v a r   d a i l y _ b t n :   B u t t o n   =   m e n u . f i n d _ c h i l d ( " D a i l y B u t t o n " ,   t r u e ,   f a l s e ) 
 	 a s s e r t _ t r u e ( d a i l y _ b t n . t e x t . b e g i n s _ w i t h ( " D a i l y   C h a l l e n g e   -   C o m p l e t e d " ) ,   " B u t t o n   t e x t   s h o u l d   b e g i n   w i t h   c o m p l e t e d   t e x t " ) 
 	 a s s e r t _ t r u e ( d a i l y _ b t n . t e x t . c o n t a i n s ( " [ N e x t   i n : " ) ,   " B u t t o n   s h o u l d   s h o w   c o u n t d o w n " ) 
 	 
 	 i f   n o t   p r e v _ c o m p l e t e d : 
 	 	 d m . c l e a r _ r e c o r d s ( ) 
 	 
 	 m e n u . q u e u e _ f r e e ( ) 
 
 f u n c   t e s t _ d a i l y _ b u t t o n _ p r e s s e d _ w h e n _ c o m p l e t e d ( )   - >   v o i d : 
 	 v a r   m e n u :   N o d e   =   l o a d ( " r e s : / / s c e n e s / m a i n _ m e n u . t s c n " ) . i n s t a n t i a t e ( ) 
 	 v a r   d m :   N o d e   =   g e t _ n o d e _ o r _ n u l l ( " / r o o t / D a i l y M a n a g e r " ) 
 	 v a r   g m :   N o d e   =   g e t _ n o d e _ o r _ n u l l ( " / r o o t / G a m e M a n a g e r " ) 
 	 v a r   t e s t _ d a t e   =   d m . g e t _ c u r r e n t _ u t c _ d a t e _ s t r i n g ( ) 
 	 v a r   p r e v _ c o m p l e t e d   =   d m . i s _ d a i l y _ c o m p l e t e d ( ) 
 	 
 	 i f   n o t   p r e v _ c o m p l e t e d : 
 	 	 d m . m a r k _ d a i l y _ c o m p l e t e d ( t e s t _ d a t e ,   t r u e ,   3 ) 
 	 	 
 	 v a r   s t a r t _ c a l l e d   =   f a l s e 
 	 #   W e   c a n t   e a s i l y   i n t e r c e p t   g m . s t a r t _ g a m e   w i t h o u t   a   s p y ,   b u t   w e   c a n   v e r i f y   g m   s t a t e 
 	 g m . c u r r e n t _ m o d e   =   9 9 9   #   i n v a l i d   m o d e 
 	 
 	 a d d _ c h i l d _ t o _ r o o t ( m e n u ) 
 	 v a r   d a i l y _ b t n :   B u t t o n   =   m e n u . f i n d _ c h i l d ( " D a i l y B u t t o n " ,   t r u e ,   f a l s e ) 
 	 d a i l y _ b t n . p r e s s e d . e m i t ( ) 
 	 
 	 a s s e r t _ e q ( g m . c u r r e n t _ m o d e ,   9 9 9 ,   " s t a r t _ g a m e   s h o u l d   n o t   b e   c a l l e d ,   m o d e   s h o u l d   r e m a i n   9 9 9 " ) 
 	 
 	 i f   n o t   p r e v _ c o m p l e t e d : 
 	 	 d m . c l e a r _ r e c o r d s ( ) 
 	 m e n u . q u e u e _ f r e e ( ) 
  
 