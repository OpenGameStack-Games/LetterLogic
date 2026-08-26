# autoloads/share_manager.gd
extends Node

## ShareManager AutoLoad
## Formats and broadcasts Daily Challenge results via native Android Share sheet
## or system clipboard with standard emoji grids and Google Play links.

const GameManagerScript = preload("res://autoloads/game_manager.gd")

const PLAY_STORE_URL: String = "https://play.google.com/store/apps/details?id=com.opengamestack.letterlogic"

const EMOJI_CORRECT: String = "🟩"
const EMOJI_PRESENT: String = "🟨"
const EMOJI_ABSENT: String = "⬛"

## Converts a GameManager.TileState enum into the corresponding square emoji.
func tile_state_to_emoji(state: int) -> String:
	match state:
		GameManagerScript.TileState.CORRECT:
			return EMOJI_CORRECT
		GameManagerScript.TileState.PRESENT:
			return EMOJI_PRESENT
		GameManagerScript.TileState.ABSENT:
			return EMOJI_ABSENT
		_:
			return EMOJI_ABSENT

## Formats the complete shareable text block for a Daily Challenge result.
func generate_share_text(date_str: String, guess_results: Array, won: bool, attempts: int) -> String:
	var score_str: String = "%d/6" % attempts if won else "X/6"
	var header: String = "LetterLogic %s %s" % [date_str, score_str]
	
	var grid_lines: Array[String] = []
	for row_results in guess_results:
		var line_emojis: String = ""
		for tile_state in row_results:
			line_emojis += tile_state_to_emoji(int(tile_state))
		grid_lines.append(line_emojis)
	
	var body_grid: String = "\n".join(grid_lines)
	var footer: String = "Play now: %s" % PLAY_STORE_URL
	
	return "%s\n\n%s\n\n%s" % [header, body_grid, footer]

## Shares the daily challenge outcome via native Android intent or clipboard.
func share_daily_results(date_str: String, guess_results: Array, won: bool, attempts: int) -> String:
	var share_text: String = generate_share_text(date_str, guess_results, won, attempts)
	
	# Set clipboard when supported
	if DisplayServer.has_feature(DisplayServer.FEATURE_CLIPBOARD):
		DisplayServer.clipboard_set(share_text)
	
	if OS.get_name() == "Android":
		_share_native_android("LetterLogic Daily Results", share_text)
	
	print_debug("ShareManager: Generated and copied share text to clipboard.")
	return share_text

func _share_native_android(title: String, text: String) -> void:
	if Engine.has_singleton("GodotAndroidShare"):
		var android_share: Object = Engine.get_singleton("GodotAndroidShare")
		if android_share != null and android_share.has_method("shareText"):
			android_share.call("shareText", title, "LetterLogic Results", text)
			return
	
	# Generic Android Java reflection via Godot OS/JNI if available
	if ClassDB.class_exists("JavaClassWrapper"):
		# Java reflection support if needed
		pass
