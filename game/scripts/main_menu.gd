# scripts/main_menu.gd
class_name MainMenu
extends Control

## Main Menu scene for LetterLogic.
## Handles game mode selection, live UTC countdowns for the Daily Challenge, and rules modal.

const GameManagerScript = preload("res://autoloads/game_manager.gd")
const DailyManagerScript = preload("res://autoloads/daily_manager.gd")
const SaveManagerScript = preload("res://autoloads/save_manager.gd")

@onready var daily_button: Button = $MarginContainer/VBox/MenuButtons/DailyButton
@onready var continuous_button: Button = $MarginContainer/VBox/MenuButtons/ContinuousButton
@onready var stats_button: Button = $MarginContainer/VBox/MenuButtons/StatsButton
@onready var how_to_play_button: Button = $MarginContainer/VBox/MenuButtons/HowToPlayButton
@onready var credits_button: Button = $MarginContainer/VBox/MenuButtons/CreditsButton
@onready var how_to_play_modal: Control = $HowToPlayModal
@onready var credits_modal: Control = $CreditsModal
@onready var countdown_timer: Timer = $CountdownTimer
@onready var mascot_rect: TextureRect = $MarginContainer/VBox/MascotRect

var _is_daily_locked: bool = false

func _ready() -> void:
	if how_to_play_modal != null:
		how_to_play_modal.visible = false
	if credits_modal != null:
		credits_modal.visible = false
		_bind_credits_links()
	_update_daily_button_state()
	if countdown_timer != null:
		countdown_timer.timeout.connect(_on_countdown_tick)
		countdown_timer.start(1.0)

func _bind_credits_links() -> void:
	if credits_modal == null: return
	
	var ogs = credits_modal.find_child("OGSBlock", true, false)
	if ogs:
		var btn = ogs.find_child("WebIconBtn", true, false)
		if btn and not btn.pressed.is_connected(_on_ogs_pressed):
			btn.pressed.connect(_on_ogs_pressed)
			
	var audrain = credits_modal.find_child("AudrainBlock", true, false)
	if audrain:
		var btn = audrain.find_child("WebIconBtn", true, false)
		if btn and not btn.pressed.is_connected(_on_audrain_pressed):
			btn.pressed.connect(_on_audrain_pressed)
			
	var github = credits_modal.find_child("GitHubBlock", true, false)
	if github:
		var btn = github.find_child("WebIconBtn", true, false)
		if btn and not btn.pressed.is_connected(_on_github_pressed):
			btn.pressed.connect(_on_github_pressed)

func _on_ogs_pressed() -> void:
	OS.shell_open("https://opengamestack.org/")

func _on_audrain_pressed() -> void:
	OS.shell_open("https://audrain.games/")

func _on_github_pressed() -> void:
	OS.shell_open("https://github.com/OpenGameStack-Games/LetterLogic")

func _update_daily_button_state(dm_override: Node = null) -> void:
	var dm: Node = dm_override if dm_override != null else (get_node_or_null("/root/DailyManager") if is_inside_tree() else null)
	if dm != null and daily_button != null:
		_is_daily_locked = dm.is_daily_completed()
		if _is_daily_locked:
			var countdown: String = dm.get_formatted_countdown_to_next_utc()
			daily_button.text = "Daily Challenge - Completed\n[Next in: %s]" % countdown
		else:
			daily_button.text = "Daily Challenge\n[Play Today's Word]"

func _on_countdown_tick(dm_override: Node = null) -> void:
	if _is_daily_locked:
		var dm: Node = dm_override if dm_override != null else (get_node_or_null("/root/DailyManager") if is_inside_tree() else null)
		if dm != null and daily_button != null:
			var countdown: String = dm.get_formatted_countdown_to_next_utc()
			daily_button.text = "Daily Challenge - Completed\n[Next in: %s]" % countdown

func _on_daily_button_pressed(dm_override: Node = null, gm_override: Node = null, sm_override: Node = null) -> void:
	var dm: Node = dm_override if dm_override != null else (get_node_or_null("/root/DailyManager") if is_inside_tree() else null)
	var gm: Node = gm_override if gm_override != null else (get_node_or_null("/root/GameManager") if is_inside_tree() else null)
	var sm: Node = sm_override if sm_override != null else (get_node_or_null("/root/SaveManager") if is_inside_tree() else null)
	
	if gm != null:
		var is_completed: bool = dm != null and dm.is_daily_completed()
		if is_completed:
			if sm != null:
				var data: Dictionary = sm.load_game_state(GameManagerScript.GameMode.DAILY)
				sm.deserialize_to_game_manager(data, gm)
		else:
			var daily_word: String = dm.get_daily_word() if dm != null else "LOGIC"
			gm.start_game(GameManagerScript.GameMode.DAILY, daily_word)
			
			# Restore in-progress daily save if present
			if sm != null and sm.has_saved_game(GameManagerScript.GameMode.DAILY):
				var data: Dictionary = sm.load_game_state(GameManagerScript.GameMode.DAILY)
				sm.deserialize_to_game_manager(data, gm)
	
	if is_inside_tree() and get_tree() != null:
		get_tree().change_scene_to_file("res://scenes/main_game.tscn")

func _on_continuous_button_pressed() -> void:
	var gm: Node = get_node_or_null("/root/GameManager")
	var sm: Node = get_node_or_null("/root/SaveManager")
	
	if gm != null:
		gm.start_game(GameManagerScript.GameMode.CONTINUOUS)
		
		# Restore in-progress continuous save if present
		if sm != null and sm.has_saved_game(GameManagerScript.GameMode.CONTINUOUS):
			var data: Dictionary = sm.load_game_state(GameManagerScript.GameMode.CONTINUOUS)
			sm.deserialize_to_game_manager(data, gm)
	
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")

func _get_stats_screen() -> Control:
	if has_node("StatsScreen"):
		return $StatsScreen as Control
	return null

func _on_stats_button_pressed() -> void:
	var stats_scr: Control = _get_stats_screen()
	if stats_scr != null:
		if stats_scr.has_method("refresh_display"):
			stats_scr.refresh_display()
		stats_scr.visible = true

func _get_how_to_play_modal() -> Control:
	if how_to_play_modal != null:
		return how_to_play_modal
	if has_node("HowToPlayModal"):
		how_to_play_modal = $HowToPlayModal as Control
	return how_to_play_modal

func _on_how_to_play_button_pressed() -> void:
	var modal: Control = _get_how_to_play_modal()
	if modal != null:
		modal.visible = true

func _on_close_how_to_play_pressed() -> void:
	var modal: Control = _get_how_to_play_modal()
	if modal != null:
		modal.visible = false

func _get_credits_modal() -> Control:
	if credits_modal != null:
		return credits_modal
	if has_node("CreditsModal"):
		credits_modal = $CreditsModal as Control
	return credits_modal

func _on_credits_button_pressed() -> void:
	var modal: Control = _get_credits_modal()
	if modal != null:
		modal.visible = true

func _on_close_credits_pressed() -> void:
	var modal: Control = _get_credits_modal()
	if modal != null:
		modal.visible = false
