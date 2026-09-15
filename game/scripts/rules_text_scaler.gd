class_name RulesTextScaler
extends RichTextLabel

const BASE_FONT_SIZE: int = 32
const MIN_FONT_SIZE: int = 14

func _ready() -> void:
	resized.connect(_on_resized)
	visibility_changed.connect(_on_visibility_changed)

func _on_resized() -> void:
	if is_visible_in_tree():
		_scale_text_to_fit()

func _on_visibility_changed() -> void:
	if is_visible_in_tree():
		_scale_text_to_fit()

func _scale_text_to_fit() -> void:
	if size.y <= 0:
		return
		
	var current_size: int = BASE_FONT_SIZE
	_set_font_sizes(current_size)
	
	# Force an update so get_content_height() is accurate
	# But get_content_height() in Godot 4 might need a frame or we can just call it
	# Actually, get_content_height() updates immediately if we don't wait? 
	# Wait, RichTextLabel needs to reshape. We might need to wait for idle frame in some cases,
	# but setting theme override font size should be synchronous enough, or not?
	# Let's check Godot 4 docs. Usually changing theme overrides requires redrawing.
	
	while current_size > MIN_FONT_SIZE and _get_current_content_height() > size.y:
		current_size -= 1
		_set_font_sizes(current_size)

func _get_current_content_height() -> int:
	return get_content_height()

func _set_font_sizes(new_size: int) -> void:
	add_theme_font_size_override("normal_font_size", new_size)
	add_theme_font_size_override("bold_font_size", new_size)
