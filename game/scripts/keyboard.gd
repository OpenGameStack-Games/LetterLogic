# scripts/keyboard.gd
class_name GameKeyboard
extends Control

## Virtual keyboard for LetterLogic.
## Supports on-screen touch and physical keyboard input.
## Dynamically disables keys for letters currently typed in the active row,
## and colors keys according to evaluated guess results.

const KeyboardKeyScript = preload("res://scripts/keyboard_key.gd")
const GameManagerScript = preload("res://autoloads/game_manager.gd")

const ROW_1: Array[String] = ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]
const ROW_2: Array[String] = ["A", "S", "D", "F", "G", "H", "J", "K", "L"]
const ROW_3: Array[String] = ["⌫", "Z", "X", "C", "V", "B", "N", "M", "ENTER"]
const KEYBOARD_BOTTOM_MARGIN_MIN: int = 8
const KEYBOARD_BOTTOM_MARGIN_MAX: int = 24
const KEYBOARD_ROW_VERTICAL_SEPARATION_MIN: int = 4
const KEYBOARD_ROW_VERTICAL_SEPARATION_MAX: int = 8
const KEYBOARD_KEY_SEPARATION_MIN: int = 3
const KEYBOARD_KEY_SEPARATION_MAX: int = 6
const KEYBOARD_SIDE_MARGIN_MIN: int = 4
const KEYBOARD_SIDE_MARGIN_MAX: int = 6
const KEYBOARD_ROW_STAGGER_MIN: int = 8
const KEYBOARD_ROW_STAGGER_MAX: int = 16
const KEY_STANDARD_MIN_WIDTH: float = 24.0
const KEY_ACTION_MIN_WIDTH: float = 44.0
const KEY_TOUCH_HEIGHT_VIEWPORT_RATIO: float = 0.066

var keys_by_letter: Dictionary = {} # String (letter) -> KeyboardKey
var vbox_container: VBoxContainer = null

func _init() -> void:
	pass

func _ready() -> void:
	_setup_keyboard()
	_refresh_responsive_metrics()
	_connect_game_manager()

func _get_minimum_size() -> Vector2:
	return Vector2(0.0, get_responsive_minimum_height())

func _setup_keyboard() -> void:
	if not has_node("MarginContainer/VBoxContainer"):
		var margin: MarginContainer = MarginContainer.new()
		margin.name = "MarginContainer"
		margin.set_anchors_preset(PRESET_FULL_RECT)
		margin.size_flags_horizontal = SIZE_EXPAND_FILL
		margin.size_flags_vertical = SIZE_EXPAND_FILL
		margin.add_theme_constant_override("margin_left", KEYBOARD_SIDE_MARGIN_MIN)
		margin.add_theme_constant_override("margin_right", KEYBOARD_SIDE_MARGIN_MIN)
		margin.add_theme_constant_override("margin_bottom", KEYBOARD_BOTTOM_MARGIN_MIN)
		add_child(margin)

		vbox_container = VBoxContainer.new()
		vbox_container.name = "VBoxContainer"
		vbox_container.size_flags_horizontal = SIZE_EXPAND_FILL
		vbox_container.size_flags_vertical = SIZE_EXPAND_FILL
		vbox_container.add_theme_constant_override("separation", KEYBOARD_ROW_VERTICAL_SEPARATION_MIN)
		margin.add_child(vbox_container)
	else:
		vbox_container = $MarginContainer/VBoxContainer as VBoxContainer

	_build_keys()
	_refresh_responsive_metrics()

func _build_keys() -> void:
	keys_by_letter.clear()
	for child in vbox_container.get_children():
		child.queue_free()

	var rows: Array = [ROW_1, ROW_2, ROW_3]
	for r_idx in range(rows.size()):
		var row_keys: Array = rows[r_idx]
		var hbox: HBoxContainer = HBoxContainer.new()
		hbox.name = "Row%d" % (r_idx + 1)
		hbox.size_flags_horizontal = SIZE_EXPAND_FILL
		hbox.size_flags_vertical = SIZE_EXPAND_FILL
		hbox.add_theme_constant_override("separation", KEYBOARD_KEY_SEPARATION_MIN)
		vbox_container.add_child(hbox)

		# Add slight left/right spacing for row 2 to give standard staggered look
		if r_idx == 1:
			var spacer_left: Control = Control.new()
			spacer_left.name = "LeftStaggerSpacer"
			spacer_left.custom_minimum_size = Vector2(KEYBOARD_ROW_STAGGER_MIN, 0)
			hbox.add_child(spacer_left)

		for key_str in row_keys:
			var key_btn: Node = KeyboardKeyScript.new()
			var min_w: float = KEY_STANDARD_MIN_WIDTH
			if key_str == "ENTER" or key_str == "⌫":
				min_w = KEY_ACTION_MIN_WIDTH

			key_btn.setup(key_str, min_w, KeyboardKeyScript.KEY_MIN_TOUCH_HEIGHT)
			key_btn.on_key_pressed.connect(_on_key_clicked)
			hbox.add_child(key_btn)

			if key_str.length() == 1 and key_str != "⌫":
				keys_by_letter[key_str] = key_btn

		if r_idx == 1:
			var spacer_right: Control = Control.new()
			spacer_right.name = "RightStaggerSpacer"
			spacer_right.custom_minimum_size = Vector2(KEYBOARD_ROW_STAGGER_MIN, 0)
			hbox.add_child(spacer_right)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_refresh_responsive_metrics()

func get_responsive_minimum_height() -> float:
	var row_gap: int = _get_row_separation()
	var bottom_gap: int = _get_bottom_margin()
	return (_get_key_touch_height() * 3.0) + (float(row_gap) * 2.0) + float(bottom_gap)

func _refresh_responsive_metrics() -> void:
	var margin_container: MarginContainer = get_node_or_null("MarginContainer") as MarginContainer
	if margin_container != null:
		var side_margin: int = _get_side_margin()
		margin_container.add_theme_constant_override("margin_left", side_margin)
		margin_container.add_theme_constant_override("margin_right", side_margin)
		margin_container.add_theme_constant_override("margin_bottom", _get_bottom_margin())

	if vbox_container != null:
		vbox_container.add_theme_constant_override("separation", _get_row_separation())
		for row_node in vbox_container.get_children():
			if row_node is HBoxContainer:
				var hbox: HBoxContainer = row_node as HBoxContainer
				hbox.add_theme_constant_override("separation", _get_key_separation())
				for child in hbox.get_children():
					if child is KeyboardKey:
						var key: KeyboardKey = child as KeyboardKey
						var min_width: float = KEY_ACTION_MIN_WIDTH if key.text == "ENTER" or key.text == "⌫" else KEY_STANDARD_MIN_WIDTH
						key.custom_minimum_size = Vector2(min_width, _get_key_touch_height())
						key.update_minimum_size()
						if key.has_method("_refresh_font_size"):
							key.call("_refresh_font_size")
					elif child is Control:
						var spacer: Control = child as Control
						spacer.custom_minimum_size = Vector2(_get_row_stagger_width(), 0.0)
	update_minimum_size()

func _get_viewport_size() -> Vector2:
	if is_inside_tree() and get_viewport() != null:
		return get_viewport_rect().size
	return size

func _get_bottom_margin() -> int:
	var viewport_size: Vector2 = _get_viewport_size()
	if viewport_size.y <= 0.0:
		return KEYBOARD_BOTTOM_MARGIN_MIN
	return int(round(clampf(viewport_size.y * 0.015, float(KEYBOARD_BOTTOM_MARGIN_MIN), float(KEYBOARD_BOTTOM_MARGIN_MAX))))

func _get_row_separation() -> int:
	var viewport_size: Vector2 = _get_viewport_size()
	if viewport_size.y <= 0.0:
		return KEYBOARD_ROW_VERTICAL_SEPARATION_MIN
	return int(round(clampf(viewport_size.y * 0.006, float(KEYBOARD_ROW_VERTICAL_SEPARATION_MIN), float(KEYBOARD_ROW_VERTICAL_SEPARATION_MAX))))

func _get_key_separation() -> int:
	var viewport_size: Vector2 = _get_viewport_size()
	if viewport_size.x <= 0.0:
		return KEYBOARD_KEY_SEPARATION_MIN
	return int(round(clampf(viewport_size.x * 0.008, float(KEYBOARD_KEY_SEPARATION_MIN), float(KEYBOARD_KEY_SEPARATION_MAX))))

func _get_key_touch_height() -> float:
	var viewport_size: Vector2 = _get_viewport_size()
	if viewport_size.y <= 0.0:
		return KeyboardKeyScript.KEY_MIN_TOUCH_HEIGHT
	return clampf(viewport_size.y * KEY_TOUCH_HEIGHT_VIEWPORT_RATIO, KeyboardKeyScript.KEY_MIN_TOUCH_HEIGHT, KeyboardKeyScript.KEY_MAX_TOUCH_HEIGHT)

func _get_side_margin() -> int:
	var viewport_size: Vector2 = _get_viewport_size()
	if viewport_size.x <= 0.0:
		return KEYBOARD_SIDE_MARGIN_MIN
	return int(round(clampf(viewport_size.x * 0.012, float(KEYBOARD_SIDE_MARGIN_MIN), float(KEYBOARD_SIDE_MARGIN_MAX))))

func _get_row_stagger_width() -> int:
	var viewport_size: Vector2 = _get_viewport_size()
	if viewport_size.x <= 0.0:
		return KEYBOARD_ROW_STAGGER_MIN
	return int(round(clampf(viewport_size.x * 0.032, float(KEYBOARD_ROW_STAGGER_MIN), float(KEYBOARD_ROW_STAGGER_MAX))))

var _game_manager_ref: Node = null

func set_game_manager(gm: Node) -> void:
	_game_manager_ref = gm

func get_game_manager() -> Node:
	if _game_manager_ref != null and is_instance_valid(_game_manager_ref):
		return _game_manager_ref
	if is_inside_tree() and get_node_or_null("/root/GameManager") != null:
		_game_manager_ref = get_node("/root/GameManager")
	return _game_manager_ref

func _connect_game_manager() -> void:
	var gm: Node = get_game_manager()
	if gm != null:
		if not gm.letter_added.is_connected(_on_letter_added):
			gm.letter_added.connect(_on_letter_added)
		if not gm.letter_removed.is_connected(_on_letter_removed):
			gm.letter_removed.connect(_on_letter_removed)
		if not gm.guess_submitted.is_connected(_on_guess_submitted):
			gm.guess_submitted.connect(_on_guess_submitted)
		if not gm.game_reset.is_connected(_on_game_reset):
			gm.game_reset.connect(_on_game_reset)

func _on_key_clicked(key_str: String) -> void:
	var gm: Node = get_game_manager()
	if gm == null or gm.game_status != GameManagerScript.GameStatus.IN_PROGRESS:
		return

	if key_str == "ENTER":
		gm.submit_guess()
	elif key_str == "⌫" or key_str == "BACKSPACE":
		gm.remove_letter()
	else:
		gm.add_letter(key_str)

func _unhandled_input(event: InputEvent) -> void:
	var gm: Node = get_game_manager()
	if gm != null and gm.game_status != GameManagerScript.GameStatus.IN_PROGRESS:
		return

	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var key_event: InputEventKey = event as InputEventKey
		if key_event.keycode == KEY_ENTER or key_event.keycode == KEY_KP_ENTER:
			_on_key_clicked("ENTER")
			get_viewport().set_input_as_handled()
		elif key_event.keycode == KEY_BACKSPACE:
			_on_key_clicked("⌫")
			get_viewport().set_input_as_handled()
		elif key_event.keycode >= KEY_A and key_event.keycode <= KEY_Z:
			var char_str: String = String.chr(key_event.unicode).to_upper()
			if char_str.length() == 1 and char_str >= "A" and char_str <= "Z":
				_on_key_clicked(char_str)
				get_viewport().set_input_as_handled()

func _on_letter_added(letter: String, _col: int, _row: int) -> void:
	var upper: String = letter.to_upper()
	if keys_by_letter.has(upper):
		var key_node: Node = keys_by_letter[upper]
		if key_node != null and key_node.has_method("set_row_disabled"):
			key_node.set_row_disabled(true)

func _on_letter_removed(_col: int, _row: int) -> void:
	var gm: Node = get_game_manager()
	var active_typed: Array = []
	if gm != null and gm.has_method("get_typed_letters_in_current_row"):
		active_typed = gm.get_typed_letters_in_current_row()

	for letter in keys_by_letter.keys():
		var key_node: Node = keys_by_letter[letter]
		if key_node != null and key_node.has_method("set_row_disabled"):
			key_node.set_row_disabled(active_typed.has(letter))

func _on_guess_submitted(_row: int, _guess: String, _results: Array) -> void:
	var gm: Node = get_game_manager()

	# Re-enable all keys for the new row and update colors
	for letter in keys_by_letter.keys():
		var key_node: Node = keys_by_letter[letter]
		if key_node != null:
			if key_node.has_method("set_row_disabled"):
				key_node.set_row_disabled(false)
			if gm != null and gm.has_method("get_letter_state") and key_node.has_method("set_key_state"):
				var state: int = gm.get_letter_state(letter)
				key_node.set_key_state(state)

func _on_game_reset() -> void:
	reset_keyboard()

func reset_keyboard() -> void:
	for letter in keys_by_letter.keys():
		var key_node: Node = keys_by_letter[letter]
		if key_node != null and key_node.has_method("reset"):
			key_node.reset()

func get_key(letter: String) -> Node:
	var upper: String = letter.to_upper()
	if keys_by_letter.has(upper):
		return keys_by_letter[upper]
	return null

## Repopulates keyboard key states and active row restrictions from GameManager.
func populate_from_manager(gm_override: Node = null) -> void:
	var gm: Node = gm_override if gm_override != null else get_game_manager()
	if gm == null:
		return

	reset_keyboard()
	for letter in keys_by_letter.keys():
		var key_node: Node = keys_by_letter[letter]
		if key_node != null and key_node.has_method("set_key_state") and gm.has_method("get_letter_state"):
			var state: int = gm.get_letter_state(letter)
			key_node.set_key_state(state)

	if gm.has_method("get_typed_letters_in_current_row"):
		var active_typed: Array = gm.get_typed_letters_in_current_row()
		for letter in keys_by_letter.keys():
			var key_node: Node = keys_by_letter[letter]
			if key_node != null and key_node.has_method("set_row_disabled"):
				key_node.set_row_disabled(active_typed.has(letter))
