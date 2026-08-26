# scripts/main_menu.gd
class_name MainMenu
extends Control

## Main Menu scene for LetterLogic.
## Handles game mode selection, live UTC countdowns for the Daily Challenge, and rules modal.

const GameManagerScript = preload("res://autoloads/game_manager.gd")
const DailyManagerScript = preload("res://autoloads/daily_manager.gd")
const SaveManagerScript = preload("res://autoloads/save_manager.gd")

@onready var daily_button: Button = $CenterContainer/VBox/MenuButtons/DailyButton
@onready var continuous_button: Button = $CenterContainer/VBox/MenuButtons/ContinuousButton
@onready var stats_button: Button = $CenterContainer/VBox/MenuButtons/StatsButton
@onready var how_to_play_button: Button = $CenterContainer/VBox/MenuButtons/HowToPlayButton
@onready var how_to_play_modal: Control = $HowToPlayModal
@onready var countdown_timer: Timer = $CountdownTimer

var _is_daily_locked: bool = false

func _ready() -> void:
	if how_to_play_modal != null:
		how_to_play_modal.visible = false
	_update_daily_button_state()
	if countdown_timer != null:
		countdown_timer.timeout.connect(_on_countdown_tick)
		countdown_timer.start(1.0)

func _update_daily_button_state() -> void:
	var dm: Node = get_node_or_null("/root/DailyManager")
	if dm != null and daily_button != null:
		_is_daily_locked = dm.is_daily_completed()
		if _is_daily_locked:
			var countdown: String = dm.get_formatted_countdown_to_next_utc()
			daily_button.text = "Daily Challenge\n[Next in: %s]" % countdown
		else:
			daily_button.text = "Daily Challenge\n[Play Today's Word]"

func _on_countdown_tick() -> void:
	if _is_daily_locked:
		var dm: Node = get_node_or_null("/root/DailyManager")
		if dm != null and daily_button != null:
			var countdown: String = dm.get_formatted_countdown_to_next_utc()
			daily_button.text = "Daily Challenge\n[Next in: %s]" % countdown

func _on_daily_button_pressed() -> void:
	var dm: Node = get_node_or_null("/root/DailyManager")
	var gm: Node = get_node_or_null("/root/GameManager")
	var sm: Node = get_node_or_null("/root/SaveManager")
	
	if gm != null:
		var daily_word: String = dm.get_daily_word() if dm != null else "LOGIC"
		gm.start_game(GameManagerScript.GameMode.DAILY, daily_word)
		
		# Restore in-progress daily save if present
		if sm != null and sm.has_saved_game(GameManagerScript.GameMode.DAILY):
			var data: Dictionary = sm.load_game_state(GameManagerScript.GameMode.DAILY)
			sm.deserialize_to_game_manager(data, gm)
	
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
