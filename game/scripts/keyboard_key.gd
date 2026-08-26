# scripts/keyboard_key.gd
class_name KeyboardKey
extends Button

## Represents a single touch/mouse key on the LetterLogic virtual keyboard.

const GameManagerScript = preload("res://autoloads/game_manager.gd")

const COLOR_BG_DEFAULT: Color = Color("818384")
const COLOR_BG_CORRECT: Color = Color("538d4e")
const COLOR_BG_PRESENT: Color = Color("b59f3b")
const COLOR_BG_ABSENT: Color = Color("3a3a3c")
const COLOR_BG_DISABLED: Color = Color("272729")

const COLOR_TEXT_DEFAULT: Color = Color("ffffff")
const COLOR_TEXT_ABSENT: Color = Color("808080")
const COLOR_TEXT_DISABLED: Color = Color("505050")

var key_name: String = ""
var key_state: int = 0 # GameManager.TileState
var is_row_disabled: bool = false

signal on_key_pressed(key: String)

func _ready() -> void:
	pressed.connect(_on_pressed)
	focus_mode = FOCUS_NONE
	_update_visuals()

func setup(p_key_name: String, min_w: float = 48.0, min_h: float = 64.0) -> void:
	key_name = p_key_name
	text = p_key_name
	custom_minimum_size = Vector2(min_w, min_h)
	size_flags_horizontal = SIZE_EXPAND_FILL
	size_flags_vertical = SIZE_EXPAND_FILL
	_update_visuals()

func _on_pressed() -> void:
	on_key_pressed.emit(key_name)

## Sets whether the key is disabled because it is currently typed in the active row.
func set_row_disabled(disabled_flag: bool) -> void:
	is_row_disabled = disabled_flag
	disabled = disabled_flag
	_update_visuals()

## Sets the confirmed TileState (CORRECT, PRESENT, ABSENT, EMPTY) from evaluated guesses.
func set_key_state(new_state: int) -> void:
	key_state = new_state
	_update_visuals()

func _update_visuals() -> void:
	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	style_box.corner_radius_top_left = 6
	style_box.corner_radius_top_right = 6
	style_box.corner_radius_bottom_left = 6
	style_box.corner_radius_bottom_right = 6
	
	var text_color: Color = COLOR_TEXT_DEFAULT
	
	if is_row_disabled:
		style_box.bg_color = COLOR_BG_DISABLED
		text_color = COLOR_TEXT_DISABLED
	else:
		match key_state:
			GameManagerScript.TileState.CORRECT:
				style_box.bg_color = COLOR_BG_CORRECT
				text_color = COLOR_TEXT_DEFAULT
			GameManagerScript.TileState.PRESENT:
				style_box.bg_color = COLOR_BG_PRESENT
				text_color = COLOR_TEXT_DEFAULT
			GameManagerScript.TileState.ABSENT:
				style_box.bg_color = COLOR_BG_ABSENT
				text_color = COLOR_TEXT_ABSENT
			_:
				style_box.bg_color = COLOR_BG_DEFAULT
				text_color = COLOR_TEXT_DEFAULT
	
	add_theme_stylebox_override("normal", style_box)
	add_theme_stylebox_override("hover", style_box)
	add_theme_stylebox_override("pressed", style_box)
	add_theme_stylebox_override("disabled", style_box)
	add_theme_color_override("font_color", text_color)
	add_theme_color_override("font_disabled_color", text_color)
	add_theme_color_override("font_hover_color", text_color)
	add_theme_color_override("font_pressed_color", text_color)

func reset() -> void:
	key_state = GameManagerScript.TileState.EMPTY
	is_row_disabled = false
	disabled = false
	_update_visuals()
