# tests/test_share_manager.gd
extends "res://tests/test_base.gd"

## Automated unit tests for ShareManager formatting and Android sharing logic.

const ShareManagerScript = preload("res://autoloads/share_manager.gd")
const GameManagerScript = preload("res://autoloads/game_manager.gd")

var share_mgr: Node = null

func _init() -> void:
	share_mgr = ShareManagerScript.new()

func cleanup() -> void:
	if share_mgr != null and is_instance_valid(share_mgr):
		share_mgr.free()
		share_mgr = null

func test_tile_state_to_emoji() -> void:
	assert_eq(share_mgr.tile_state_to_emoji(GameManagerScript.TileState.CORRECT), "🟩", "CORRECT should map to 🟩")
	assert_eq(share_mgr.tile_state_to_emoji(GameManagerScript.TileState.PRESENT), "🟨", "PRESENT should map to 🟨")
	assert_eq(share_mgr.tile_state_to_emoji(GameManagerScript.TileState.ABSENT), "⬛", "ABSENT should map to ⬛")

func test_generate_share_text_win() -> void:
	var date_str: String = "2026-08-26"
	var dummy_results: Array = [
		[GameManagerScript.TileState.ABSENT, GameManagerScript.TileState.ABSENT, GameManagerScript.TileState.PRESENT, GameManagerScript.TileState.ABSENT, GameManagerScript.TileState.CORRECT],
		[GameManagerScript.TileState.ABSENT, GameManagerScript.TileState.CORRECT, GameManagerScript.TileState.ABSENT, GameManagerScript.TileState.ABSENT, GameManagerScript.TileState.CORRECT],
		[GameManagerScript.TileState.CORRECT, GameManagerScript.TileState.CORRECT, GameManagerScript.TileState.CORRECT, GameManagerScript.TileState.CORRECT, GameManagerScript.TileState.CORRECT]
	]
	
	var text: String = share_mgr.generate_share_text(date_str, dummy_results, true, 3)
	
	assert_true(text.begins_with("LetterLogic 2026-08-26 3/6"), "Header should format correctly with 3/6")
	assert_true(text.contains("⬛⬛🟨⬛🟩"), "Row 1 emojis should match")
	assert_true(text.contains("⬛🟩⬛⬛🟩"), "Row 2 emojis should match")
	assert_true(text.contains("🟩🟩🟩🟩🟩"), "Row 3 emojis should match")
	assert_true(text.contains("https://play.google.com/store/apps/details?id=com.opengamestack.letterlogic"), "Footer should contain Google Play link")

func test_generate_share_text_loss() -> void:
	var date_str: String = "2026-08-26"
	var dummy_results: Array = [
		[GameManagerScript.TileState.ABSENT, GameManagerScript.TileState.ABSENT, GameManagerScript.TileState.ABSENT, GameManagerScript.TileState.ABSENT, GameManagerScript.TileState.ABSENT],
		[GameManagerScript.TileState.ABSENT, GameManagerScript.TileState.ABSENT, GameManagerScript.TileState.ABSENT, GameManagerScript.TileState.ABSENT, GameManagerScript.TileState.ABSENT],
		[GameManagerScript.TileState.ABSENT, GameManagerScript.TileState.ABSENT, GameManagerScript.TileState.ABSENT, GameManagerScript.TileState.ABSENT, GameManagerScript.TileState.ABSENT],
		[GameManagerScript.TileState.ABSENT, GameManagerScript.TileState.ABSENT, GameManagerScript.TileState.ABSENT, GameManagerScript.TileState.ABSENT, GameManagerScript.TileState.ABSENT],
		[GameManagerScript.TileState.ABSENT, GameManagerScript.TileState.ABSENT, GameManagerScript.TileState.ABSENT, GameManagerScript.TileState.ABSENT, GameManagerScript.TileState.ABSENT],
		[GameManagerScript.TileState.ABSENT, GameManagerScript.TileState.ABSENT, GameManagerScript.TileState.ABSENT, GameManagerScript.TileState.ABSENT, GameManagerScript.TileState.ABSENT]
	]
	
	var text: String = share_mgr.generate_share_text(date_str, dummy_results, false, 6)
	assert_true(text.begins_with("LetterLogic 2026-08-26 X/6"), "Lost game header should format as X/6")
	assert_true(text.contains("⬛⬛⬛⬛⬛"), "Row emojis should be all absent")

func test_share_daily_results_clipboard() -> void:
	var dummy_results: Array = [
		[GameManagerScript.TileState.CORRECT, GameManagerScript.TileState.CORRECT, GameManagerScript.TileState.CORRECT, GameManagerScript.TileState.CORRECT, GameManagerScript.TileState.CORRECT]
	]
	var generated: String = share_mgr.share_daily_results("2026-08-26", dummy_results, true, 1)
	assert_true(generated.contains("LetterLogic 2026-08-26 1/6"), "Returned string must contain header")
	assert_true(generated.contains("🟩🟩🟩🟩🟩"), "Returned string must contain green emojis")
	if DisplayServer.has_feature(DisplayServer.FEATURE_CLIPBOARD):
		var clipboard_content: String = DisplayServer.clipboard_get()
		assert_eq(clipboard_content, generated, "Clipboard should receive generated share text")
