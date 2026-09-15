class_name StatsScreen
extends Control

## Displays player statistics and guess distribution separated by game mode.

const GameManagerScript = preload("res://autoloads/game_manager.gd")
const StatsManagerScript = preload("res://autoloads/stats_manager.gd")

const BASE_CONTENT_MARGIN_TOP: int = 48

@onready var content_margin: MarginContainer = $"MarginContainer"
@onready var mode_tabs: TabContainer = $"MarginContainer/VBox/ModeTabs"
@onready var content_vbox: VBoxContainer = $"MarginContainer/VBox/ModeTabs/Continuous Play/ContentVBox"

var played_val: Label
var win_pct_val: Label
var streak_val: Label
var max_streak_val: Label
var best_time_val: Label
var avg_time_val: Label
var dist_container: VBoxContainer

var active_mode: int = 0 # 0 = Continuous, 1 = Daily
var _stats_manager_ref: Node = null

func _ready() -> void:
	_apply_safe_area_insets()
	_update_node_references()
	if mode_tabs != null and not mode_tabs.tab_changed.is_connected(_on_tab_changed):
		mode_tabs.tab_changed.connect(_on_tab_changed)
	refresh_display()

func _apply_safe_area_insets() -> void:
	if content_margin == null:
		content_margin = get_node_or_null("MarginContainer") as MarginContainer
	SafeAreaLayout.apply_margin_container_top_margin(content_margin, BASE_CONTENT_MARGIN_TOP)

func _update_node_references() -> void:
	if mode_tabs == null:
		mode_tabs = get_node_or_null("MarginContainer/VBox/ModeTabs") as TabContainer
	if content_vbox == null and mode_tabs != null:
		content_vbox = mode_tabs.find_child("ContentVBox", true, false) as VBoxContainer
		
	if content_vbox != null and played_val == null and content_vbox.has_node("SummaryCards/PlayedCard/Value"):
		played_val = content_vbox.get_node("SummaryCards/PlayedCard/Value") as Label
		win_pct_val = content_vbox.get_node("SummaryCards/WinPctCard/Value") as Label
		streak_val = content_vbox.get_node("SummaryCards/StreakCard/Value") as Label
		max_streak_val = content_vbox.get_node("SummaryCards/MaxStreakCard/Value") as Label
		best_time_val = content_vbox.get_node("SummaryCards/BestTimeCard/Value") as Label
		avg_time_val = content_vbox.get_node("SummaryCards/AvgTimeCard/Value") as Label
		dist_container = content_vbox.get_node("DistributionContainer") as VBoxContainer

func _on_tab_changed(tab: int) -> void:
	_update_node_references()
	# Tab 0 is Continuous Play, Tab 1 is Daily Challenge
	if tab == 0:
		active_mode = GameManagerScript.GameMode.CONTINUOUS
	else:
		active_mode = GameManagerScript.GameMode.DAILY
	
	if mode_tabs != null and content_vbox != null and tab < mode_tabs.get_child_count():
		var current_tab_node: Node = mode_tabs.get_child(tab)
		if content_vbox.get_parent() != current_tab_node:
			content_vbox.owner = null
			content_vbox.get_parent().remove_child(content_vbox)
			current_tab_node.add_child(content_vbox)
	
	refresh_display()

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
	_update_node_references()
	var target_tab: int = 0 if mode == GameManagerScript.GameMode.CONTINUOUS else 1
	if mode_tabs != null:
		if mode_tabs.current_tab != target_tab:
			mode_tabs.current_tab = target_tab
	_on_tab_changed(target_tab)

func refresh_display() -> void:
	_update_node_references()
	var sm: Node = get_stats_manager()
	var stats: Dictionary = {}
	var win_pct: int = 0
	var best_time: float = 0.0
	var avg_time: float = 0.0
	
	if sm != null:
		stats = sm.get_stats_for_mode(active_mode)
		win_pct = sm.get_win_percentage(active_mode)
		best_time = sm.get_best_time(active_mode)
		avg_time = sm.get_average_time(active_mode)
	else:
		stats = {
			"played": 0, "won": 0, "current_streak": 0, "max_streak": 0,
			"distribution": { "1": 0, "2": 0, "3": 0, "4": 0, "5": 0, "6": 0, "loss": 0 }
		}
	
	if played_val != null:
		played_val.text = str(int(stats.get("played", 0)))
	if win_pct_val != null:
		win_pct_val.text = "%d%%" % win_pct
	if streak_val != null:
		streak_val.text = str(int(stats.get("current_streak", 0)))
	if max_streak_val != null:
		max_streak_val.text = str(int(stats.get("max_streak", 0)))
	if best_time_val != null:
		best_time_val.text = GameManagerScript.format_time(best_time) if best_time > 0 else "--:--"
	if avg_time_val != null:
		avg_time_val.text = GameManagerScript.format_time(avg_time) if avg_time > 0 else "--:--"
	
	_update_distribution(stats.get("distribution", {}))

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
		row_hbox.custom_minimum_size = Vector2(0, 48)
		row_hbox.add_theme_constant_override("separation", 8)
		
		# Label (1..6 or L)
		var label_str: String = "X" if k == "loss" else k
		var lbl: Label = Label.new()
		lbl.text = label_str
		lbl.custom_minimum_size = Vector2(36, 0)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 24)
		row_hbox.add_child(lbl)
		
		# Bar panel
		var bar_pct: float = float(count) / float(max_val) if max_val > 0 else 0.0
		bar_pct = maxf(bar_pct, 0.08) # Min width so count is readable
		
		var bar_panel: PanelContainer = PanelContainer.new()
		bar_panel.size_flags_horizontal = SIZE_EXPAND_FILL
		bar_panel.size_flags_stretch_ratio = bar_pct
		
		var style: StyleBoxFlat = StyleBoxFlat.new()
		style.bg_color = Color("538d4e") if k != "loss" and count > 0 else Color("3a3a3c")
		style.corner_radius_top_left = 6
		style.corner_radius_top_right = 6
		style.corner_radius_bottom_left = 6
		style.corner_radius_bottom_right = 6
		bar_panel.add_theme_stylebox_override("panel", style)
		
		var count_lbl: Label = Label.new()
		count_lbl.text = " %d " % count
		count_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		count_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		count_lbl.add_theme_font_size_override("font_size", 22)
		bar_panel.add_child(count_lbl)
		
		row_hbox.add_child(bar_panel)
		
		# Empty spacer to right to maintain proper bar proportions
		var spacer: Control = Control.new()
		spacer.size_flags_horizontal = SIZE_EXPAND_FILL
		spacer.size_flags_stretch_ratio = maxf(1.0 - bar_pct, 0.01)
		row_hbox.add_child(spacer)
		
		dist_container.add_child(row_hbox)

func _on_close_pressed() -> void:
	visible = false

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_safe_area_insets()
