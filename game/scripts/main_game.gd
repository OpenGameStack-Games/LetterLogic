# scripts/main_game.gd
class_name MainGame
extends Control

## Primary game scene orchestrating the top header, GameBoard, GameKeyboard, and game over overlays.

const GameManagerScript = preload("res://autoloads/game_manager.gd")
const SaveManagerScript = preload("res://autoloads/save_manager.gd")
const DailyManagerScript = preload("res://autoloads/daily_manager.gd")

@onready var game_board: Control = $VBoxContainer/BoardArea/GameBoard
@onready var game_keyboard: Control = $VBoxContainer/KeyboardArea/Keyboard
@onready var mode_label: Label = $VBoxContainer/Header/ModeLabel
@onready var toast_label: Label = $ToastOverlay/ToastPanel/ToastLabel
@onready var toast_overlay: Control = $ToastOverlay
@onready var game_over_modal: Control = $GameOverModal
@onready var game_over_title: Label = $GameOverModal/Panel/VBox/TitleLabel
@onready var game_over_message: Label = $GameOverModal/Panel/VBox/MessageLabel
@onready var next_word_btn: Button = $GameOverModal/Panel/VBox/ButtonContainer/NextWordButton
@onready var share_btn: Button = $GameOverModal/Panel/VBox/ButtonContainer/ShareButton
@onready var toast_timer: Timer = $ToastOverlay/ToastTimer

func _ready() -> void:
	if toast_overlay != null:
		toast_overlay.visible = false
	if game_over_modal != null:
		game_over_modal.visible = false
	_connect_signals()
	_update_header()

func _connect_signals() -> void:
	var gm: Node = get_node_or_null("/root/GameManager")
	if gm != null:
		if not gm.invalid_guess.is_connected(_on_invalid_guess):
			gm.invalid_guess.connect(_on_invalid_guess)
		if not gm.game_won.is_connected(_on_game_won):
			gm.game_won.connect(_on_game_won)
		if not gm.game_lost.is_connected(_on_game_lost):
			gm.game_lost.connect(_on_game_lost)

func _update_header() -> void:
	var gm: Node = get_node_or_null("/root/GameManager")
	if gm != null and mode_label != null:
		if gm.current_mode == GameManagerScript.GameMode.DAILY:
			var dm: Node = get_node_or_null("/root/DailyManager")
			var date_str: String = dm.get_current_utc_date_string() if dm != null else "DAILY"
			mode_label.text = "DAILY CHALLENGE • %s" % date_str
		else:
			mode_label.text = "CONTINUOUS PLAY"

func _on_invalid_guess(reason: String) -> void:
	show_toast(reason)

func show_toast(msg: String) -> void:
	if toast_overlay != null and toast_label != null:
		toast_label.text = msg
		toast_overlay.visible = true
		if toast_timer != null:
			toast_timer.start(1.8)

func _on_toast_timer_timeout() -> void:
	if toast_overlay != null:
		toast_overlay.visible = false

func _on_game_won(attempts: int, secret: String) -> void:
	var titles: Array[String] = ["Genius!", "Magnificent!", "Impressive!", "Splendid!", "Great!", "Phew!"]
	var idx: int = clampi(attempts - 1, 0, titles.size() - 1)
	var win_title: String = titles[idx]
	_show_game_over(win_title, "You found '%s' in %d/6 guesses." % [secret, attempts], true)

func _on_game_lost(secret: String) -> void:
	_show_game_over("Game Over", "The word was %s" % secret, false)

func _show_game_over(title_text: String, msg_text: String, won: bool) -> void:
	var gm: Node = get_node_or_null("/root/GameManager")
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

func _on_back_to_menu_pressed() -> void:
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
		sm.share_daily_results(date_str, gm.guess_results, won, attempts)
	
	show_toast("Results copied to clipboard!")

func _on_stats_pressed() -> void:
	if has_node("StatsScreen"):
		var stats_scr: Control = $StatsScreen as Control
		if stats_scr != null:
			var gm: Node = get_node_or_null("/root/GameManager")
			if gm != null and stats_scr.has_method("set_mode"):
				stats_scr.set_mode(gm.current_mode)
			elif stats_scr.has_method("refresh_display"):
				stats_scr.refresh_display()
			stats_scr.visible = true
