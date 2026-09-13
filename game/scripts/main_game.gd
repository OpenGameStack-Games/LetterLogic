# scripts/main_game.gd
class_name MainGame
extends Control

## Primary game scene orchestrating the top header, GameBoard, GameKeyboard, and game over overlays.

const GameManagerScript = preload("res://autoloads/game_manager.gd")
const SaveManagerScript = preload("res://autoloads/save_manager.gd")
const DailyManagerScript = preload("res://autoloads/daily_manager.gd")

@onready var game_board: Control = $VBoxContainer/BoardArea/GameBoard
@onready var game_keyboard: Control = $VBoxContainer/KeyboardArea/Keyboard
@onready var mode_label: Label = $VBoxContainer/Header/TitleBox/ModeLabel
@onready var toast_label: Label = $VBoxContainer/ToastOverlay/ToastPanel/MarginContainer/ToastLabel
@onready var toast_overlay: Control = $VBoxContainer/ToastOverlay
@onready var game_over_modal: Control = $GameOverModal
@onready var game_over_title: Label = $GameOverModal/MarginContainer/Panel/VBox/TitleLabel
@onready var game_over_message: Label = $GameOverModal/MarginContainer/Panel/VBox/MessageLabel
@onready var next_word_btn: Button = $GameOverModal/MarginContainer/Panel/VBox/ButtonMargin/ButtonContainer/NextWordButton
@onready var share_btn: Button = $GameOverModal/MarginContainer/Panel/VBox/ButtonMargin/ButtonContainer/ShareButton
@onready var toast_timer: Timer = $VBoxContainer/ToastOverlay/ToastTimer

func _ready() -> void:
	if toast_overlay == null:
		toast_overlay = find_child("ToastOverlay", true, false) as Control
	if toast_label == null and toast_overlay != null:
		toast_label = toast_overlay.find_child("ToastLabel", true, false) as Label
	if toast_timer == null and toast_overlay != null:
		toast_timer = toast_overlay.find_child("ToastTimer", true, false) as Timer
	if toast_overlay != null:
		toast_overlay.modulate.a = 0.0
	if game_over_modal != null:
		game_over_modal.visible = false
	_connect_signals()
	_update_header()
	check_and_restore_completed_game()

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
		mode_label = get_node_or_null("VBoxContainer/Header/TitleBox/ModeLabel") as Label
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
		var time_lbl: Label = get_node_or_null("VBoxContainer/Header/TitleBox/TimerLabel") as Label
		if time_lbl != null:
			time_lbl.text = gm.format_time(gm.get_active_time())

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
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

