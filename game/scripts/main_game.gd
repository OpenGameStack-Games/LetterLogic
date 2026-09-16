# scripts/main_game.gd
class_name MainGame
extends Control

## Primary game scene orchestrating the top header, GameBoard, GameKeyboard, and game over overlays.

const GameManagerScript = preload("res://autoloads/game_manager.gd")
const SaveManagerScript = preload("res://autoloads/save_manager.gd")
const DailyManagerScript = preload("res://autoloads/daily_manager.gd")

const CONTENT_MARGIN_SIDE_MIN: int = 12
const CONTENT_MARGIN_SIDE_MAX: int = 24
const CONTENT_MARGIN_SIDE_RATIO: float = 0.04

# Portrait layout allocation targets. Safe-area insets stay on ContentMargin; these
# explicit flow children provide breathing room so the board and keyboard remain balanced.
const TOP_BUFFER_HEIGHT_RATIO: float = 0.02
const TOP_BUFFER_HEIGHT_MIN: int = 12
const TOP_BUFFER_HEIGHT_MAX: int = 36
const HEADER_HEIGHT_RATIO: float = 0.11
const HEADER_HEIGHT_MIN: int = 76
const HEADER_HEIGHT_MAX: int = 320
const KEYBOARD_HEIGHT_RATIO: float = 0.22
const KEYBOARD_HEIGHT_MIN: int = 160
const KEYBOARD_HEIGHT_MAX: int = 620
const BOTTOM_BUFFER_HEIGHT_RATIO: float = 0.0175
const BOTTOM_BUFFER_HEIGHT_MIN: int = 10
const BOTTOM_BUFFER_HEIGHT_MAX: int = 36
const CONTENT_SEPARATION_RATIO: float = 0.008
const CONTENT_SEPARATION_MIN: int = 4
const CONTENT_SEPARATION_MAX: int = 12
const BOARD_STRETCH_RATIO: float = 2.7
const KEYBOARD_STRETCH_RATIO: float = 1.0
const HEADER_BUTTON_SIZE_MIN: int = 48
const HEADER_BUTTON_SIZE_MAX: int = 64

@onready var content_margin: MarginContainer = $ContentMargin
@onready var content_container: VBoxContainer = $ContentMargin/VBoxContainer
@onready var top_breathing_buffer: Control = $ContentMargin/VBoxContainer/TopBreathingBuffer
@onready var header: Control = $ContentMargin/VBoxContainer/Header
@onready var board_area: Control = $ContentMargin/VBoxContainer/BoardArea
@onready var keyboard_area: Control = $ContentMargin/VBoxContainer/KeyboardArea
@onready var bottom_breathing_buffer: Control = $ContentMargin/VBoxContainer/BottomBreathingBuffer
@onready var game_board: Control = $ContentMargin/VBoxContainer/BoardArea/GameBoard
@onready var game_keyboard: Control = $ContentMargin/VBoxContainer/KeyboardArea/Keyboard
@onready var mode_label: Label = $ContentMargin/VBoxContainer/Header/TitleBox/ModeLabel
@onready var title_label: Label = $ContentMargin/VBoxContainer/Header/TitleBox/TitleLabel
@onready var timer_label: Label = $ContentMargin/VBoxContainer/Header/TitleBox/TimerLabel
@onready var back_button: Button = $ContentMargin/VBoxContainer/Header/BackButton
@onready var stats_button: Button = $ContentMargin/VBoxContainer/Header/StatsButton
@onready var toast_label: Label = $ContentMargin/VBoxContainer/ToastOverlay/ToastPanel/MarginContainer/ToastLabel
@onready var toast_overlay: Control = $ContentMargin/VBoxContainer/ToastOverlay
@onready var game_over_modal: Control = $GameOverModal
@onready var game_over_title: Label = $GameOverModal/MarginContainer/Panel/VBox/TitleLabel
@onready var game_over_message: Label = $GameOverModal/MarginContainer/Panel/VBox/MessageLabel
@onready var next_word_btn: Button = $GameOverModal/MarginContainer/Panel/VBox/ButtonMargin/ButtonContainer/NextWordButton
@onready var share_btn: Button = $GameOverModal/MarginContainer/Panel/VBox/ButtonMargin/ButtonContainer/ShareButton
@onready var toast_timer: Timer = $ContentMargin/VBoxContainer/ToastOverlay/ToastTimer

func _ready() -> void:
	_apply_safe_area_insets()
	if toast_overlay == null:
		toast_overlay = find_child("ToastOverlay", true, false) as Control
	if toast_label == null and toast_overlay != null:
		toast_label = toast_overlay.find_child("ToastLabel", true, false) as Label
	if toast_timer == null and toast_overlay != null:
		toast_timer = toast_overlay.find_child("ToastTimer", true, false) as Timer
	if toast_overlay != null:
		toast_overlay.visible = false
		toast_overlay.modulate.a = 0.0
	if game_over_modal != null:
		game_over_modal.visible = false
	_connect_signals()
	_update_header()
	check_and_restore_completed_game()

func _apply_safe_area_insets() -> void:
	if content_margin == null:
		content_margin = get_node_or_null("ContentMargin") as MarginContainer
	if content_container == null:
		content_container = get_node_or_null("ContentMargin/VBoxContainer") as VBoxContainer
	_apply_proportional_portrait_layout()

func _apply_proportional_portrait_layout() -> void:
	var viewport_size: Vector2 = size
	if (viewport_size.x <= 0.0 or viewport_size.y <= 0.0) and is_inside_tree():
		viewport_size = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = get_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = Vector2(360.0, 800.0)

	var safe_area: Rect2i = DisplayServer.get_display_safe_area()
	var safe_top: int = maxi(safe_area.position.y, 0)
	var safe_bottom_edge: int = safe_area.position.y + safe_area.size.y
	var safe_bottom: int = maxi(int(round(viewport_size.y)) - safe_bottom_edge, 0)
	if not _is_safe_area_compatible_with_viewport(safe_area, viewport_size):
		safe_top = 0
		safe_bottom = 0
	var available_height: float = maxf(viewport_size.y - float(safe_top + safe_bottom), 1.0)

	_cache_layout_nodes()
	_apply_content_margin(viewport_size, safe_top, safe_bottom)
	_apply_content_flow_metrics(available_height)
	_apply_header_metrics(viewport_size, available_height)

	if board_area != null:
		board_area.size_flags_vertical = SIZE_EXPAND_FILL
		board_area.size_flags_stretch_ratio = BOARD_STRETCH_RATIO
		board_area.custom_minimum_size = Vector2.ZERO
		board_area.update_minimum_size()

	if keyboard_area != null:
		keyboard_area.size_flags_vertical = SIZE_EXPAND_FILL
		keyboard_area.size_flags_stretch_ratio = KEYBOARD_STRETCH_RATIO
		keyboard_area.custom_minimum_size = Vector2(0.0, _ratio_clamped(available_height, KEYBOARD_HEIGHT_RATIO, float(KEYBOARD_HEIGHT_MIN), float(KEYBOARD_HEIGHT_MAX)))
		keyboard_area.update_minimum_size()

	if game_keyboard != null:
		game_keyboard.size_flags_vertical = SIZE_EXPAND_FILL
		if game_keyboard.has_method("_refresh_responsive_metrics"):
			game_keyboard.call("_refresh_responsive_metrics")
	if game_board != null:
		game_board.size_flags_vertical = SIZE_EXPAND_FILL
		if game_board.has_method("_refresh_responsive_metrics"):
			game_board.call("_refresh_responsive_metrics")

	if content_container != null:
		content_container.queue_sort()

func _cache_layout_nodes() -> void:
	if top_breathing_buffer == null:
		top_breathing_buffer = get_node_or_null("ContentMargin/VBoxContainer/TopBreathingBuffer") as Control
	if header == null:
		header = get_node_or_null("ContentMargin/VBoxContainer/Header") as Control
	if board_area == null:
		board_area = get_node_or_null("ContentMargin/VBoxContainer/BoardArea") as Control
	if keyboard_area == null:
		keyboard_area = get_node_or_null("ContentMargin/VBoxContainer/KeyboardArea") as Control
	if bottom_breathing_buffer == null:
		bottom_breathing_buffer = get_node_or_null("ContentMargin/VBoxContainer/BottomBreathingBuffer") as Control
	if game_board == null:
		game_board = get_node_or_null("ContentMargin/VBoxContainer/BoardArea/GameBoard") as Control
	if game_keyboard == null:
		game_keyboard = get_node_or_null("ContentMargin/VBoxContainer/KeyboardArea/Keyboard") as Control
	if title_label == null:
		title_label = get_node_or_null("ContentMargin/VBoxContainer/Header/TitleBox/TitleLabel") as Label
	if mode_label == null:
		mode_label = get_node_or_null("ContentMargin/VBoxContainer/Header/TitleBox/ModeLabel") as Label
	if timer_label == null:
		timer_label = get_node_or_null("ContentMargin/VBoxContainer/Header/TitleBox/TimerLabel") as Label
	if back_button == null:
		back_button = get_node_or_null("ContentMargin/VBoxContainer/Header/BackButton") as Button
	if stats_button == null:
		stats_button = get_node_or_null("ContentMargin/VBoxContainer/Header/StatsButton") as Button

func _apply_content_margin(viewport_size: Vector2, safe_top: int, safe_bottom: int) -> void:
	if content_margin == null:
		return
	var side_margin: int = int(round(clampf(viewport_size.x * CONTENT_MARGIN_SIDE_RATIO, float(CONTENT_MARGIN_SIDE_MIN), float(CONTENT_MARGIN_SIDE_MAX))))
	content_margin.add_theme_constant_override("margin_left", side_margin)
	content_margin.add_theme_constant_override("margin_right", side_margin)
	content_margin.add_theme_constant_override("margin_top", safe_top)
	content_margin.add_theme_constant_override("margin_bottom", safe_bottom)

func _apply_content_flow_metrics(available_height: float) -> void:
	if content_container != null:
		var separation: int = int(round(clampf(available_height * CONTENT_SEPARATION_RATIO, float(CONTENT_SEPARATION_MIN), float(CONTENT_SEPARATION_MAX))))
		content_container.add_theme_constant_override("separation", separation)

	if top_breathing_buffer != null:
		top_breathing_buffer.size_flags_vertical = SIZE_SHRINK_BEGIN
		top_breathing_buffer.custom_minimum_size = Vector2(0.0, _ratio_clamped(available_height, TOP_BUFFER_HEIGHT_RATIO, float(TOP_BUFFER_HEIGHT_MIN), float(TOP_BUFFER_HEIGHT_MAX)))
		top_breathing_buffer.update_minimum_size()

	if bottom_breathing_buffer != null:
		bottom_breathing_buffer.size_flags_vertical = SIZE_SHRINK_BEGIN
		bottom_breathing_buffer.custom_minimum_size = Vector2(0.0, _ratio_clamped(available_height, BOTTOM_BUFFER_HEIGHT_RATIO, float(BOTTOM_BUFFER_HEIGHT_MIN), float(BOTTOM_BUFFER_HEIGHT_MAX)))
		bottom_breathing_buffer.update_minimum_size()

func _apply_header_metrics(viewport_size: Vector2, available_height: float) -> void:
	if header != null:
		header.size_flags_vertical = SIZE_SHRINK_BEGIN
		header.custom_minimum_size = Vector2(0.0, _ratio_clamped(available_height, HEADER_HEIGHT_RATIO, float(HEADER_HEIGHT_MIN), float(HEADER_HEIGHT_MAX)))
		header.update_minimum_size()

	var title_size: int = int(round(clampf(viewport_size.x * 0.10, 34.0, 48.0)))
	var mode_size: int = int(round(clampf(viewport_size.x * 0.052, 18.0, 28.0)))
	var timer_size: int = int(round(clampf(viewport_size.x * 0.06, 20.0, 32.0)))
	var button_size: int = int(round(clampf(available_height * 0.065, float(HEADER_BUTTON_SIZE_MIN), float(HEADER_BUTTON_SIZE_MAX))))

	if title_label != null:
		title_label.add_theme_font_size_override("font_size", title_size)
	if mode_label != null:
		mode_label.add_theme_font_size_override("font_size", mode_size)
	if timer_label != null:
		timer_label.add_theme_font_size_override("font_size", timer_size)
	if back_button != null:
		back_button.custom_minimum_size = Vector2(button_size, button_size)
		back_button.add_theme_font_size_override("font_size", int(round(button_size * 0.55)))
		back_button.update_minimum_size()
	if stats_button != null:
		stats_button.custom_minimum_size = Vector2(button_size, button_size)
		stats_button.update_minimum_size()

func _ratio_clamped(height_basis: float, ratio: float, min_value: float, max_value: float) -> float:
	return clampf(height_basis * ratio, min_value, max_value)

func _is_safe_area_compatible_with_viewport(safe_area: Rect2i, viewport_size: Vector2) -> bool:
	if safe_area.size.x <= 0 or safe_area.size.y <= 0:
		return false
	var width_ratio: float = float(safe_area.size.x) / maxf(viewport_size.x, 1.0)
	var height_ratio: float = float(safe_area.size.y) / maxf(viewport_size.y, 1.0)
	return width_ratio >= 0.75 and width_ratio <= 1.25 and height_ratio >= 0.75 and height_ratio <= 1.25

func get_portrait_layout_region_rects(viewport_size: Vector2) -> Dictionary:
	var safe_area: Rect2i = DisplayServer.get_display_safe_area()
	var safe_top: int = maxi(safe_area.position.y, 0)
	var safe_bottom_edge: int = safe_area.position.y + safe_area.size.y
	var safe_bottom: int = maxi(int(round(viewport_size.y)) - safe_bottom_edge, 0)
	if not _is_safe_area_compatible_with_viewport(safe_area, viewport_size):
		safe_top = 0
		safe_bottom = 0

	var side_margin: float = clampf(viewport_size.x * CONTENT_MARGIN_SIDE_RATIO, float(CONTENT_MARGIN_SIDE_MIN), float(CONTENT_MARGIN_SIDE_MAX))
	var available_height: float = maxf(viewport_size.y - float(safe_top + safe_bottom), 1.0)
	var separation: float = clampf(available_height * CONTENT_SEPARATION_RATIO, float(CONTENT_SEPARATION_MIN), float(CONTENT_SEPARATION_MAX))
	var top_height: float = _ratio_clamped(available_height, TOP_BUFFER_HEIGHT_RATIO, float(TOP_BUFFER_HEIGHT_MIN), float(TOP_BUFFER_HEIGHT_MAX))
	var header_height: float = _ratio_clamped(available_height, HEADER_HEIGHT_RATIO, float(HEADER_HEIGHT_MIN), float(HEADER_HEIGHT_MAX))
	var keyboard_height: float = _ratio_clamped(available_height, KEYBOARD_HEIGHT_RATIO, float(KEYBOARD_HEIGHT_MIN), float(KEYBOARD_HEIGHT_MAX))
	var bottom_height: float = _ratio_clamped(available_height, BOTTOM_BUFFER_HEIGHT_RATIO, float(BOTTOM_BUFFER_HEIGHT_MIN), float(BOTTOM_BUFFER_HEIGHT_MAX))
	var content_width: float = maxf(viewport_size.x - (side_margin * 2.0), 1.0)
	var board_height: float = maxf(available_height - top_height - header_height - keyboard_height - bottom_height - (separation * 4.0), 1.0)
	var y: float = float(safe_top)
	var regions: Dictionary = {}
	regions["top"] = Rect2(Vector2(side_margin, y), Vector2(content_width, top_height))
	y += top_height + separation
	regions["header"] = Rect2(Vector2(side_margin, y), Vector2(content_width, header_height))
	y += header_height + separation
	regions["board"] = Rect2(Vector2(side_margin, y), Vector2(content_width, board_height))
	y += board_height + separation
	regions["keyboard"] = Rect2(Vector2(side_margin, y), Vector2(content_width, keyboard_height))
	y += keyboard_height + separation
	regions["bottom"] = Rect2(Vector2(side_margin, y), Vector2(content_width, bottom_height))
	return regions

func check_and_restore_completed_game(gm_override: Node = null) -> void:
	var gm: Node = gm_override if gm_override != null else (get_node_or_null("/root/GameManager") if is_inside_tree() else null)
	if gm != null:
		if game_board != null and game_board.has_method("populate_from_manager"):
			game_board.populate_from_manager(gm)
		if game_keyboard != null and game_keyboard.has_method("populate_from_manager"):
			game_keyboard.populate_from_manager(gm)
		
		if gm.game_status != GameManagerScript.GameStatus.IN_PROGRESS:
			# Immediately show game over modal
			var won: bool = gm.game_status == GameManagerScript.GameStatus.WON
			if won:
				var attempts: int = gm.current_row
				var time_str: String = gm.format_time(gm.get_active_time()) if gm.has_method("format_time") else "00:00"
				var titles: Array[String] = ["Genius!", "Magnificent!", "Impressive!", "Splendid!", "Great!", "Phew!"]
				var idx: int = clampi(attempts - 1, 0, titles.size() - 1)
				var msg: String = "You found '%s' in %d/6 guesses.\nTime: %s" % [gm.secret_word, attempts, time_str]
				_show_game_over(titles[idx], msg, true, gm)
			else:
				_show_game_over("Game Over", "The word was %s" % gm.secret_word, false, gm)
			
			# Disable inputs
			set_process_input(false)
			set_process_unhandled_input(false)
			if game_keyboard != null:
				game_keyboard.mouse_filter = Control.MOUSE_FILTER_IGNORE
				game_keyboard.set_process_unhandled_input(false)

func _connect_signals() -> void:
	var gm: Node = get_node_or_null("/root/GameManager") if is_inside_tree() else null
	if gm != null:
		if not gm.invalid_guess.is_connected(_on_invalid_guess):
			gm.invalid_guess.connect(_on_invalid_guess)
		if not gm.game_won.is_connected(_on_game_won):
			gm.game_won.connect(_on_game_won)
		if not gm.game_lost.is_connected(_on_game_lost):
			gm.game_lost.connect(_on_game_lost)

func _update_header(gm_override: Node = null, dm_override: Node = null) -> void:
	if mode_label == null:
		mode_label = get_node_or_null("ContentMargin/VBoxContainer/Header/TitleBox/ModeLabel") as Label
	var gm: Node = gm_override if gm_override != null else (get_node_or_null("/root/GameManager") if is_inside_tree() else null)
	if gm != null and mode_label != null:
		if gm.current_mode == GameManagerScript.GameMode.DAILY:
			var dm: Node = dm_override if dm_override != null else (get_node_or_null("/root/DailyManager") if is_inside_tree() else null)
			var date_str: String = dm.get_current_utc_date_string() if dm != null else "DAILY"
			mode_label.text = "DAILY CHALLENGE • %s" % date_str
		else:
			mode_label.text = "CONTINUOUS PLAY"

func _on_invalid_guess(reason: String) -> void:
	show_toast(reason)

func show_toast(msg: String) -> void:
	if toast_overlay == null:
		toast_overlay = find_child("ToastOverlay", true, false) as Control
	if toast_label == null and toast_overlay != null:
		toast_label = toast_overlay.find_child("ToastLabel", true, false) as Label
	if toast_timer == null and toast_overlay != null:
		toast_timer = toast_overlay.find_child("ToastTimer", true, false) as Timer
	if toast_overlay != null and toast_label != null:
		toast_overlay.visible = true
		toast_label.text = msg
		var tween: Tween = create_tween()
		tween.tween_property(toast_overlay, "modulate:a", 1.0, 0.15)
		if toast_timer != null and toast_timer.is_inside_tree():
			toast_timer.start(1.8)

func _on_toast_timer_timeout() -> void:
	if toast_overlay == null:
		toast_overlay = find_child("ToastOverlay", true, false) as Control
	if toast_overlay != null:
		var tween: Tween = create_tween()
		tween.tween_property(toast_overlay, "modulate:a", 0.0, 0.3)
		tween.finished.connect(_hide_toast_overlay)

func _hide_toast_overlay() -> void:
	if toast_overlay != null:
		toast_overlay.visible = false

func _on_game_won(attempts: int, secret: String, gm_override: Node = null, dm_override: Node = null, sm_override: Node = null) -> void:
	var titles: Array[String] = ["Genius!", "Magnificent!", "Impressive!", "Splendid!", "Great!", "Phew!"]
	var idx: int = clampi(attempts - 1, 0, titles.size() - 1)
	var win_title: String = titles[idx]
	
	var gm: Node = gm_override if gm_override != null else (get_node_or_null("/root/GameManager") if is_inside_tree() else null)
	var time_str: String = "00:00"
	if gm != null:
		var time_val: float = gm.get_active_time() if gm.has_method("get_active_time") else 0.0
		time_str = gm.format_time(time_val) if gm.has_method("format_time") else "00:00"
		
	var msg: String = "You found '%s' in %d/6 guesses.\nTime: %s" % [secret, attempts, time_str]
	
	if gm != null and gm.current_mode == GameManagerScript.GameMode.DAILY:
		var dm: Node = dm_override if dm_override != null else (get_node_or_null("/root/DailyManager") if is_inside_tree() else null)
		if dm != null and dm.has_method("mark_daily_completed"):
			var date_str: String = dm.get_current_utc_date_string()
			dm.mark_daily_completed(date_str, true, attempts)
		var sm: Node = sm_override if sm_override != null else (get_node_or_null("/root/SaveManager") if is_inside_tree() else null)
		if sm != null and sm.has_method("save_game_state"):
			sm.save_game_state(GameManagerScript.GameMode.DAILY, sm.serialize_game_manager(gm))
	elif gm != null and gm.current_mode == GameManagerScript.GameMode.CONTINUOUS:
		var sm: Node = sm_override if sm_override != null else (get_node_or_null("/root/SaveManager") if is_inside_tree() else null)
		if sm != null and sm.has_method("clear_game_state"):
			sm.clear_game_state(GameManagerScript.GameMode.CONTINUOUS)
	if is_inside_tree():
		await get_tree().create_timer(1.5).timeout
			
	_show_game_over(win_title, msg, true, gm)

func _on_game_lost(secret: String, gm_override: Node = null, dm_override: Node = null, sm_override: Node = null) -> void:
	var gm: Node = gm_override if gm_override != null else (get_node_or_null("/root/GameManager") if is_inside_tree() else null)
	if gm != null and gm.current_mode == GameManagerScript.GameMode.DAILY:
		var dm: Node = dm_override if dm_override != null else (get_node_or_null("/root/DailyManager") if is_inside_tree() else null)
		if dm != null and dm.has_method("mark_daily_completed"):
			var date_str: String = dm.get_current_utc_date_string()
			dm.mark_daily_completed(date_str, false, 6) # Assume 6 attempts for loss
		var sm: Node = sm_override if sm_override != null else (get_node_or_null("/root/SaveManager") if is_inside_tree() else null)
		if sm != null and sm.has_method("save_game_state"):
			sm.save_game_state(GameManagerScript.GameMode.DAILY, sm.serialize_game_manager(gm))
	elif gm != null and gm.current_mode == GameManagerScript.GameMode.CONTINUOUS:
		var sm: Node = sm_override if sm_override != null else (get_node_or_null("/root/SaveManager") if is_inside_tree() else null)
		if sm != null and sm.has_method("clear_game_state"):
			sm.clear_game_state(GameManagerScript.GameMode.CONTINUOUS)
	if is_inside_tree():
		await get_tree().create_timer(1.5).timeout
			
	_show_game_over("Game Over", "The word was %s" % secret, false, gm)

func _show_game_over(title_text: String, msg_text: String, won: bool, gm_override: Node = null) -> void:
	var gm: Node = gm_override if gm_override != null else (get_node_or_null("/root/GameManager") if is_inside_tree() else null)
	var is_daily: bool = gm != null and gm.current_mode == GameManagerScript.GameMode.DAILY
	
	if game_over_modal != null:
		if game_over_title != null:
			game_over_title.text = title_text
		if game_over_message != null:
			game_over_message.text = msg_text
		if share_btn != null:
			share_btn.visible = is_daily
		if next_word_btn != null:
			next_word_btn.visible = not is_daily
		game_over_modal.visible = true
		
		if is_inside_tree():
			game_over_modal.modulate.a = 0.0
			game_over_modal.scale = Vector2(0.8, 0.8)
			game_over_modal.pivot_offset = game_over_modal.size / 2.0
			var tween: Tween = create_tween()
			tween.set_parallel(true)
			tween.tween_property(game_over_modal, "modulate:a", 1.0, 0.3)
			tween.tween_property(game_over_modal, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_back_to_menu_pressed() -> void:
	var gm: Node = get_node_or_null("/root/GameManager")
	var sm: Node = get_node_or_null("/root/SaveManager")
	if gm != null and sm != null and gm.game_status == GameManagerScript.GameStatus.IN_PROGRESS:
		sm.save_game_state(gm.current_mode, sm.serialize_game_manager(gm))
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_next_word_pressed() -> void:
	if game_over_modal != null:
		game_over_modal.visible = false
	var gm: Node = get_node_or_null("/root/GameManager")
	if gm != null:
		gm.start_game(GameManagerScript.GameMode.CONTINUOUS)

func _on_share_pressed() -> void:
	var gm: Node = get_node_or_null("/root/GameManager")
	var dm: Node = get_node_or_null("/root/DailyManager")
	var sm: Node = get_node_or_null("/root/ShareManager")
	
	if gm != null and dm != null and sm != null:
		var date_str: String = dm.get_current_utc_date_string()
		var won: bool = gm.game_status == GameManagerScript.GameStatus.WON
		var attempts: int = gm.current_row
		var active_time: float = gm.get_active_time() if gm.has_method("get_active_time") else 0.0
		sm.share_daily_results(date_str, gm.guess_results, won, attempts, active_time)
	
	show_toast("Results copied to clipboard!")

func _on_stats_pressed() -> void:
	if has_node("StatsScreen"):
		var stats_scr: Control = $StatsScreen as Control
		if stats_scr != null:
			var gm: Node = get_node_or_null("/root/GameManager")
			if gm != null:
				if stats_scr.has_method("set_mode"):
					stats_scr.set_mode(gm.current_mode)
				elif stats_scr.has_method("refresh_display"):
					stats_scr.refresh_display()
				if gm.has_method("pause_timer"):
					gm.pause_timer()
				if not stats_scr.visibility_changed.is_connected(_on_stats_visibility_changed):
					stats_scr.visibility_changed.connect(_on_stats_visibility_changed)
			stats_scr.visible = true

func _on_stats_visibility_changed() -> void:
	var stats_scr: Control = get_node_or_null("StatsScreen") as Control
	if stats_scr != null and not stats_scr.visible:
		var gm: Node = get_node_or_null("/root/GameManager")
		if gm != null and gm.has_method("resume_timer"):
			if not _is_overlay_blocking():
				gm.resume_timer()

func _is_overlay_blocking() -> bool:
	if game_over_modal != null and game_over_modal.visible:
		return true
	if has_node("StatsScreen"):
		var stats_scr: Control = get_node("StatsScreen") as Control
		if stats_scr != null and stats_scr.visible:
			return true
	return false

func _process(_delta: float) -> void:
	var gm: Node = get_node_or_null("/root/GameManager")
	if gm != null:
		var time_lbl: Label = get_node_or_null("ContentMargin/VBoxContainer/Header/TitleBox/TimerLabel") as Label
		if time_lbl != null:
			time_lbl.text = gm.format_time(gm.get_active_time())

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_safe_area_insets()
	elif what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		var gm: Node = get_node_or_null("/root/GameManager")
		if gm != null:
			if gm.has_method("pause_timer"):
				gm.pause_timer()
			var sm: Node = get_node_or_null("/root/SaveManager")
			if sm != null and gm.game_status == GameManagerScript.GameStatus.IN_PROGRESS:
				sm.save_game_state(gm.current_mode, sm.serialize_game_manager(gm))
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN or what == NOTIFICATION_APPLICATION_RESUMED:
		var gm: Node = get_node_or_null("/root/GameManager")
		if gm != null and gm.has_method("resume_timer"):
			if not _is_overlay_blocking():
				gm.resume_timer()
