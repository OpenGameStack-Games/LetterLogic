# scripts/tile.gd
class_name GameTile
extends PanelContainer

## Represents a single tile cell in the LetterLogic game grid.

const GameManagerScript = preload("res://autoloads/game_manager.gd")

const COLOR_BG_EMPTY: Color = Color("121213")
const COLOR_BG_TYPING: Color = Color("121213")
const COLOR_BG_CORRECT: Color = Color("538d4e")
const COLOR_BG_PRESENT: Color = Color("b59f3b")
const COLOR_BG_ABSENT: Color = Color("3a3a3c")

const COLOR_BORDER_EMPTY: Color = Color("3a3a3c")
const COLOR_BORDER_TYPING: Color = Color("565758")
const COLOR_BORDER_CORRECT: Color = Color("538d4e")
const COLOR_BORDER_PRESENT: Color = Color("b59f3b")
const COLOR_BORDER_ABSENT: Color = Color("3a3a3c")

const COLOR_TEXT: Color = Color("ffffff")

var label: Label = null
var current_state: int = 0
var letter: String = ""

func _ready() -> void:
	_ensure_label()
	set_state(GameManagerScript.TileState.EMPTY)

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
			lbl.add_theme_font_size_override("font_size", 32)
			add_child(lbl)
			label = lbl

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

func reset() -> void:
	_ensure_label()
	letter = ""
	if label != null:
		label.text = ""
	set_state(GameManagerScript.TileState.EMPTY)
