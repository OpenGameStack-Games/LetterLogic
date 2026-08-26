# scripts/stats_screen.gd
class_name StatsScreen
extends Control

## Displays player statistics and guess distribution separated by game mode.

const GameManagerScript = preload("res://autoloads/game_manager.gd")
const StatsManagerScript = preload("res://autoloads/stats_manager.gd")

@onready var daily_tab_btn: Button = $Panel/VBox/ModeTabs/DailyTabButton
@onready var continuous_tab_btn: Button = $Panel/VBox/ModeTabs/ContinuousTabButton

@onready var played_val: Label = $Panel/VBox/SummaryCards/PlayedCard/Value
@onready var win_pct_val: Label = $Panel/VBox/SummaryCards/WinPctCard/Value
@onready var streak_val: Label = $Panel/VBox/SummaryCards/StreakCard/Value
@onready var max_streak_val: Label = $Panel/VBox/SummaryCards/MaxStreakCard/Value

@onready var dist_container: VBoxContainer = $Panel/VBox/DistributionContainer

var active_mode: int = 0 # 0 = Continuous, 1 = Daily
var _stats_manager_ref: Node = null

func _ready() -> void:
	_ensure_nodes()
	refresh_display()

func _ensure_nodes() -> void:
	if played_val == null and has_node("Panel/VBox/SummaryCards/PlayedCard/Value"):
		played_val = $Panel/VBox/SummaryCards/PlayedCard/Value as Label
	if win_pct_val == null and has_node("Panel/VBox/SummaryCards/WinPctCard/Value"):
		win_pct_val = $Panel/VBox/SummaryCards/WinPctCard/Value as Label
	if streak_val == null and has_node("Panel/VBox/SummaryCards/StreakCard/Value"):
		streak_val = $Panel/VBox/SummaryCards/StreakCard/Value as Label
	if max_streak_val == null and has_node("Panel/VBox/SummaryCards/MaxStreakCard/Value"):
		max_streak_val = $Panel/VBox/SummaryCards/MaxStreakCard/Value as Label
	if dist_container == null and has_node("Panel/VBox/DistributionContainer"):
		dist_container = $Panel/VBox/DistributionContainer as VBoxContainer
	if daily_tab_btn == null and has_node("Panel/VBox/ModeTabs/DailyTabButton"):
		daily_tab_btn = $Panel/VBox/ModeTabs/DailyTabButton as Button
	if continuous_tab_btn == null and has_node("Panel/VBox/ModeTabs/ContinuousTabButton"):
		continuous_tab_btn = $Panel/VBox/ModeTabs/ContinuousTabButton as Button

func set_stats_manager(sm: Node) -> void:
	_stats_manager_ref = sm

func get_stats_manager() -> Node:
	if _stats_manager_ref != null and is_instance_valid(_stats_manager_ref):
		return _stats_manager_ref
	if is_inside_tree() and get_node_or_null("/root/StatsManager") != null:
		_stats_manager_ref = get_node("/root/StatsManager")
	return _stats_manager_ref

func set_mode(mode: int) -> void:
	active_mode = mode
	refresh_display()

func refresh_display() -> void:
	_ensure_nodes()
	var sm: Node = get_stats_manager()
	var stats: Dictionary = {}
	var win_pct: int = 0
	
	if sm != null:
		stats = sm.get_stats_for_mode(active_mode)
		win_pct = sm.get_win_percentage(active_mode)
	else:
		stats = {
			"played": 0, "won": 0, "current_streak": 0, "max_streak": 0,
			"distribution": { "1": 0, "2": 0, "3": 0, "4": 0, "5": 0, "6": 0, "loss": 0 }
		}
	
	if played_val != null:
		played_val.text = str(stats.get("played", 0))
	if win_pct_val != null:
		win_pct_val.text = "%d%%" % win_pct
	if streak_val != null:
		streak_val.text = str(stats.get("current_streak", 0))
	if max_streak_val != null:
		max_streak_val.text = str(stats.get("max_streak", 0))
	
	_update_tab_buttons()
	_update_distribution(stats.get("distribution", {}))

func _update_tab_buttons() -> void:
	_ensure_nodes()
	if daily_tab_btn != null and continuous_tab_btn != null:
		if active_mode == GameManagerScript.GameMode.DAILY:
			daily_tab_btn.disabled = true
			continuous_tab_btn.disabled = false
		else:
			daily_tab_btn.disabled = false
			continuous_tab_btn.disabled = true

func _update_distribution(dist: Dictionary) -> void:
	if dist_container == null:
		return
	
	# Find max count for proportional scaling
	var max_val: int = 1
	for k in dist.keys():
		var val: int = int(dist[k])
		if val > max_val:
			max_val = val
	
	for child in dist_container.get_children():
		child.queue_free()
	
	var keys: Array[String] = ["1", "2", "3", "4", "5", "6", "loss"]
	for k in keys:
		var count: int = int(dist.get(k, 0))
		var row_hbox: HBoxContainer = HBoxContainer.new()
		row_hbox.custom_minimum_size = Vector2(0, 28)
		row_hbox.add_theme_constant_override("separation", 8)
		
		# Label (1..6 or L)
		var label_str: String = "X" if k == "loss" else k
		var lbl: Label = Label.new()
		lbl.text = label_str
		lbl.custom_minimum_size = Vector2(24, 0)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row_hbox.add_child(lbl)
		
		# Bar panel
		var bar_pct: float = float(count) / float(max_val) if max_val > 0 else 0.0
		bar_pct = maxf(bar_pct, 0.08) # Min width so count is readable
		
		var bar_panel: PanelContainer = PanelContainer.new()
		bar_panel.size_flags_horizontal = SIZE_EXPAND_FILL
		bar_panel.size_flags_stretch_ratio = bar_pct
		
		var style: StyleBoxFlat = StyleBoxFlat.new()
		style.bg_color = Color("538d4e") if k != "loss" and count > 0 else Color("3a3a3c")
		style.corner_radius_top_left = 4
		style.corner_radius_top_right = 4
		style.corner_radius_bottom_left = 4
		style.corner_radius_bottom_right = 4
		bar_panel.add_theme_stylebox_override("panel", style)
		
		var count_lbl: Label = Label.new()
		count_lbl.text = " %d " % count
		count_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		count_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		bar_panel.add_child(count_lbl)
		
		row_hbox.add_child(bar_panel)
		
		# Empty spacer to right to maintain proper bar proportions
		var spacer: Control = Control.new()
		spacer.size_flags_horizontal = SIZE_EXPAND_FILL
		spacer.size_flags_stretch_ratio = maxf(1.0 - bar_pct, 0.01)
		row_hbox.add_child(spacer)
		
		dist_container.add_child(row_hbox)

func _on_daily_tab_pressed() -> void:
	set_mode(GameManagerScript.GameMode.DAILY)

func _on_continuous_tab_pressed() -> void:
	set_mode(GameManagerScript.GameMode.CONTINUOUS)

func _on_close_pressed() -> void:
	visible = false
