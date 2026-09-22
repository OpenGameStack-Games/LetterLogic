# autoloads/share_manager.gd
extends Node

## ShareManager AutoLoad
## Formats and broadcasts Daily Challenge results via native Android Share sheet
## or system clipboard with standard emoji grids and Google Play links.

const GameManagerScript = preload("res://autoloads/game_manager.gd")

const GAME_URL: String = "https://audrain.games/letterlogic"

const EMOJI_CORRECT: String = "🟩"
const EMOJI_PRESENT: String = "🟨"
const EMOJI_ABSENT: String = "🟥"

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
func generate_share_text(date_str: String, guess_results: Array, won: bool, attempts: int, active_time: float = 0.0) -> String:
	var score_str: String = "%d/6" % attempts if won else "X/6"
	var header: String = "LetterLogic %s %s" % [date_str, score_str]
	
	var time_str: String = "⏱️ " + GameManagerScript.format_time(active_time)
	
	var grid_lines: Array[String] = []
	for row_results in guess_results:
		var line_emojis: String = ""
		for tile_state in row_results:
			line_emojis += tile_state_to_emoji(int(tile_state))
		grid_lines.append(line_emojis)
	
	var body_grid: String = "\n".join(grid_lines)
	var footer: String = "Play now: %s" % GAME_URL
	
	return "%s\n%s\n\n%s\n\n%s" % [header, time_str, body_grid, footer]

## Shares the daily challenge outcome via native Android intent or clipboard.
func share_daily_results(date_str: String, guess_results: Array, won: bool, attempts: int, active_time: float = 0.0) -> String:
	var share_text: String = generate_share_text(date_str, guess_results, won, attempts, active_time)
	
	# Set clipboard when supported
	if DisplayServer.has_feature(DisplayServer.FEATURE_CLIPBOARD):
		DisplayServer.clipboard_set(share_text)
	
	if OS.get_name() == "Android":
		_share_native_android("LetterLogic Daily Results", share_text)
	elif OS.has_feature("web"):
		_share_native_web("LetterLogic Daily Results", share_text)
	
	print_debug("ShareManager: Generated and copied share text to clipboard.")
	return share_text

func _share_native_android(title: String, text: String) -> void:
	const SHARE_SCRIPT_PATH: String = "res://addons/SharePlugin/Share.gd"
	if ResourceLoader.exists(SHARE_SCRIPT_PATH):
		var share_script: Script = load(SHARE_SCRIPT_PATH) as Script
		if share_script and share_script.can_instantiate():
			var share_node: Node = share_script.new() as Node
			add_child(share_node)
			if share_node.has_method("share_text"):
				share_node.share_text(title, title, text)
			if is_inside_tree():
				var tree: SceneTree = get_tree()
				if tree:
					tree.create_timer(2.0).timeout.connect(share_node.queue_free)
				else:
					share_node.queue_free()
			else:
				share_node.queue_free()

func _share_native_web(title: String, text: String) -> void:
	if not OS.has_feature("web"):
		return
	
	# Escape text to be safely evaluated in JS.
	# We use backticks to allow newlines, but we escape any backticks and backslashes.
	var safe_text: String = text.replace("\\", "\\\\").replace("`", "\\`")
	var js_code: String = "if (navigator.share) { navigator.share({title: '" + title + "', text: `" + safe_text + "`}).catch(console.error); } else { console.log('Web Share API not supported'); }"
	JavaScriptBridge.eval(js_code)
