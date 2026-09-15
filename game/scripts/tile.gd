# scripts/tile.gd
class_name GameTile
extends PanelContainer

## Represents a single tile cell in the LetterLogic game grid.

const GameManagerScript = preload("res://autoloads/game_manager.gd")

const COLOR_BG_EMPTY: Color = Color("121213")
const COLOR_BG_TYPING: Color = Color("121213")
const COLOR_BG_CORRECT: Color = Color("538d4e")
const COLOR_BG_PRESENT: Color = Color("b59f3b")
const COLOR_BG_ABSENT: Color = Color("b53b3b")

const COLOR_BORDER_EMPTY: Color = Color("3a3a3c")
const COLOR_BORDER_TYPING: Color = Color("565758")
const COLOR_BORDER_CORRECT: Color = Color("538d4e")
const COLOR_BORDER_PRESENT: Color = Color("b59f3b")
const COLOR_BORDER_ABSENT: Color = Color("b53b3b")

const COLOR_TEXT: Color = Color("ffffff")
const FONT_SIZE_MAX: int = 72
const FONT_SIZE_MIN: int = 16
const FONT_SIZE_SCALE: float = 0.62

var label: Label = null
var current_state: int = 0
var letter: String = ""

func _ready() -> void:
	_ensure_label()
	custom_minimum_size = Vector2.ZERO
	set_state(GameManagerScript.TileState.EMPTY)
	_refresh_font_size()

func _get_minimum_size() -> Vector2:
	return Vector2.ZERO

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_refresh_font_size()

func _ensure_label() -> void:
	if label == null:
		if has_node("Label"):
			label = $Label as Label
		else:
			var lbl: Label = Label.new()
			lbl.name = "Label"
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			lbl.add_theme_color_override("font_color", COLOR_TEXT)
			add_child(lbl)
			label = lbl
	if label != null:
		label.clip_text = true
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.size_flags_horizontal = SIZE_EXPAND_FILL
		label.size_flags_vertical = SIZE_EXPAND_FILL
		label.custom_minimum_size = Vector2.ZERO
		label.add_theme_color_override("font_color", COLOR_TEXT)
		_refresh_font_size()

func _refresh_font_size() -> void:
	if label == null:
		return
	var tile_span: float = minf(size.x, size.y)
	var target_size: int = FONT_SIZE_MAX
	if tile_span > 0.0:
		target_size = int(round(clampf(tile_span * FONT_SIZE_SCALE, float(FONT_SIZE_MIN), float(FONT_SIZE_MAX))))
	label.add_theme_font_size_override("font_size", target_size)

func set_letter(p_letter: String) -> void:
	_ensure_label()
	letter = p_letter.to_upper()
	if label != null:
		label.text = letter
	if letter.is_empty():
		set_state(GameManagerScript.TileState.EMPTY)
	else:
		set_state(GameManagerScript.TileState.TYPING)

func set_state(new_state: int) -> void:
	current_state = new_state
	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	style_box.corner_radius_top_left = 4
	style_box.corner_radius_top_right = 4
	style_box.corner_radius_bottom_left = 4
	style_box.corner_radius_bottom_right = 4
	style_box.set_border_width_all(2)

	match new_state:
		GameManagerScript.TileState.EMPTY:
			style_box.bg_color = COLOR_BG_EMPTY
			style_box.border_color = COLOR_BORDER_EMPTY
		GameManagerScript.TileState.TYPING:
			style_box.bg_color = COLOR_BG_TYPING
			style_box.border_color = COLOR_BORDER_TYPING
		GameManagerScript.TileState.CORRECT:
			style_box.bg_color = COLOR_BG_CORRECT
			style_box.border_color = COLOR_BORDER_CORRECT
		GameManagerScript.TileState.PRESENT:
			style_box.bg_color = COLOR_BG_PRESENT
			style_box.border_color = COLOR_BORDER_PRESENT
		GameManagerScript.TileState.ABSENT:
			style_box.bg_color = COLOR_BG_ABSENT
			style_box.border_color = COLOR_BORDER_ABSENT
		_:
			style_box.bg_color = COLOR_BG_EMPTY
			style_box.border_color = COLOR_BORDER_EMPTY

	add_theme_stylebox_override("panel", style_box)

func animate_reveal(new_state: int, delay: float) -> void:
	if not is_inside_tree():
		set_state(new_state)
		return
		
	var tween: Tween = create_tween()
	if delay > 0:
		tween.tween_interval(delay)
	
	# Set state and perform scale pop
	tween.tween_callback(func():
		set_state(new_state)
		pivot_offset = size / 2.0
	)
	
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func reset() -> void:
	_ensure_label()
	letter = ""
	if label != null:
		label.text = ""
	set_state(GameManagerScript.TileState.EMPTY)
