class_name SafeAreaLayout
extends RefCounted

## Applies Android display-cutout safe area insets to full-screen LetterLogic layouts.

static func get_safe_top_margin(base_margin: float, safe_area: Rect2i) -> float:
	var safe_top_inset: int = maxi(safe_area.position.y, 0)
	return base_margin + float(safe_top_inset)

static func get_safe_bottom_margin(base_margin: float, safe_area: Rect2i, viewport_height: int) -> float:
	var safe_bottom_edge: int = safe_area.position.y + safe_area.size.y
	var safe_bottom_inset: int = maxi(viewport_height - safe_bottom_edge, 0)
	return base_margin + float(safe_bottom_inset)

static func get_display_safe_top_margin(base_margin: float) -> float:
	var safe_area: Rect2i = DisplayServer.get_display_safe_area()
	return get_safe_top_margin(base_margin, safe_area)

static func get_display_safe_bottom_margin(base_margin: float, viewport_height: int) -> float:
	var safe_area: Rect2i = DisplayServer.get_display_safe_area()
	return get_safe_bottom_margin(base_margin, safe_area, viewport_height)

static func apply_control_top_offset(control: Control, base_margin: float) -> void:
	if control == null:
		push_warning("SafeAreaLayout: Cannot apply safe area top offset to a null Control.")
		return
	control.offset_top = get_display_safe_top_margin(base_margin)

static func apply_margin_container_top_margin(container: MarginContainer, base_margin: int) -> void:
	if container == null:
		push_warning("SafeAreaLayout: Cannot apply safe area top margin to a null MarginContainer.")
		return
	var safe_top_margin: int = int(round(get_display_safe_top_margin(float(base_margin))))
	container.add_theme_constant_override("margin_top", safe_top_margin)

static func apply_margin_container_vertical_safe_margins(container: MarginContainer, base_top_margin: int, base_bottom_margin: int, viewport_height: int) -> void:
	if container == null:
		push_warning("SafeAreaLayout: Cannot apply safe area vertical margins to a null MarginContainer.")
		return
	var safe_top_margin: int = int(round(get_display_safe_top_margin(float(base_top_margin))))
	var safe_bottom_margin: int = int(round(get_display_safe_bottom_margin(float(base_bottom_margin), viewport_height)))
	container.add_theme_constant_override("margin_top", safe_top_margin)
	container.add_theme_constant_override("margin_bottom", safe_bottom_margin)
