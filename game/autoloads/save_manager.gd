# autoloads/save_manager.gd
extends Node

## SaveManager AutoLoad
## Handles local persistence of game sessions (Continuous vs Daily) and player statistics.
## Guarantees robust JSON serialization, error recovery, and separate storage slots.

const GameManagerScript = preload("res://autoloads/game_manager.gd")

const SAVE_PATH_CONTINUOUS: String = "user://save_continuous.json"
const SAVE_PATH_DAILY: String = "user://save_daily.json"

func _ready() -> void:
	pass

## Returns the appropriate save file path for the given game mode.
func get_save_path(mode: int) -> String:
	if mode == GameManagerScript.GameMode.DAILY:
		return SAVE_PATH_DAILY
	return SAVE_PATH_CONTINUOUS

## Checks whether an in-progress saved game exists for the given mode.
func has_saved_game(mode: int, custom_path: String = "") -> bool:
	var path: String = custom_path if custom_path != "" else get_save_path(mode)
	return FileAccess.file_exists(path)

## Saves the dictionary state for a game mode to disk as formatted JSON.
func save_game_state(mode: int, data: Dictionary, custom_path: String = "") -> bool:
	var path: String = custom_path if custom_path != "" else get_save_path(mode)
	var json_str: String = JSON.stringify(data, "\t")
	
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: Failed to open save file '%s' for writing (Error: %s)" % [path, str(FileAccess.get_open_error())])
		return false
	
	file.store_string(json_str)
	file.close()
	print_debug("SaveManager: Saved state to '%s'" % path)
	return true

## Loads and parses the game state dictionary from disk.
## Returns an empty dictionary if file does not exist or JSON parsing fails.
func load_game_state(mode: int, custom_path: String = "") -> Dictionary:
	var path: String = custom_path if custom_path != "" else get_save_path(mode)
	if not FileAccess.file_exists(path):
		return {}
	
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("SaveManager: Failed to open save file '%s' for reading" % path)
		return {}
	
	var content: String = file.get_as_text()
	file.close()
	
	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(content)
	if parse_result != OK:
		push_warning("SaveManager: Corrupted JSON in '%s' (Error: %s). Clearing bad file." % [path, json.get_error_message()])
		clear_game_state(mode, path)
		return {}
	
	if json.data is Dictionary:
		return json.data as Dictionary
	
	return {}

## Deletes the save file for the given mode.
func clear_game_state(mode: int, custom_path: String = "") -> bool:
	var path: String = custom_path if custom_path != "" else get_save_path(mode)
	if FileAccess.file_exists(path):
		var err: Error = DirAccess.remove_absolute(path)
		if err == OK:
			print_debug("SaveManager: Cleared save file '%s'" % path)
			return true
		else:
			push_error("SaveManager: Failed to delete save file '%s' (Error: %s)" % [path, str(err)])
			return false
	return true

## Serializes the active GameManager state into a dictionary.
func serialize_game_manager(gm: Node) -> Dictionary:
	if gm == null:
		return {}
	
	var serialized_results: Array = []
	for row_res in gm.guess_results:
		var row_array: Array = []
		for tile_st in row_res:
			row_array.append(int(tile_st))
		serialized_results.append(row_array)
	
	var serialized_kb: Dictionary = {}
	for k in gm.keyboard_states.keys():
		serialized_kb[k] = int(gm.keyboard_states[k])
	
	return {
		"version": 1,
		"mode": int(gm.current_mode),
		"status": int(gm.game_status),
		"secret_word": gm.secret_word,
		"current_row": int(gm.current_row),
		"current_guess": gm.current_guess,
		"guesses": gm.guesses.duplicate(),
		"guess_results": serialized_results,
		"keyboard_states": serialized_kb
	}

## Restores saved dictionary state back into a GameManager instance.
func deserialize_to_game_manager(data: Dictionary, gm: Node) -> bool:
	if gm == null or data.is_empty():
		return false
	
	gm.current_mode = data.get("mode", GameManagerScript.GameMode.CONTINUOUS)
	gm.game_status = data.get("status", GameManagerScript.GameStatus.IN_PROGRESS)
	gm.secret_word = data.get("secret_word", "")
	gm.current_row = int(data.get("current_row", 0))
	gm.current_guess = data.get("current_guess", "")
	
	gm.guesses.clear()
	var loaded_guesses: Array = data.get("guesses", [])
	for g in loaded_guesses:
		gm.guesses.append(String(g))
	
	gm.guess_results.clear()
	var loaded_results: Array = data.get("guess_results", [])
	for r in loaded_results:
		var row_st: Array = []
		for st in r:
			row_st.append(int(st))
		gm.guess_results.append(row_st)
	
	gm.keyboard_states.clear()
	var loaded_kb: Dictionary = data.get("keyboard_states", {})
	for k in loaded_kb.keys():
		gm.keyboard_states[String(k)] = int(loaded_kb[k])
	
	return true
