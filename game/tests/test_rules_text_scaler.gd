extends "res://tests/test_base.gd"

const RulesTextScalerScript = preload("res://scripts/rules_text_scaler.gd")

class MockRulesTextScaler extends "res://scripts/rules_text_scaler.gd":
	var mock_height: float = 200.0
	func _get_current_content_height() -> int:
		# Simulate content shrinking as font size shrinks
		# Let's say for every font size tick, height decreases by 10
		var font_size = get_theme_font_size("normal_font_size")
		if font_size == 0:
			font_size = BASE_FONT_SIZE
		return int(mock_height - (32 - font_size) * 10)

func test_scaling() -> void:
	var node = MockRulesTextScaler.new()
	node.size = Vector2(400, 100) # Small height
	node.text = "Mocked text"
	
	node._scale_text_to_fit()
	
	var normal_font = node.get_theme_font_size("normal_font_size")
	var bold_font = node.get_theme_font_size("bold_font_size")
	
	assert_true(normal_font < 32, "Font size should have scaled down to fit. Size is: %s" % normal_font)
	assert_true(bold_font < 32, "Bold font size should have scaled down to fit. Size is: %s" % bold_font)
	assert_eq(normal_font, bold_font, "Normal and bold font sizes should match.")
	
	node.free()
