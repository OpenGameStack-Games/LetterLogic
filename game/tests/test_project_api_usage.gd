# tests/test_project_api_usage.gd
extends "res://tests/test_base.gd"

## Regression tests for engine API usage patterns that may only surface when runtime scenes are opened.

func test_control_minimum_size_changed_signal_is_not_called_as_method() -> void:
	var script_paths: Array[String] = _collect_gd_scripts("res://")
	assert_true(script_paths.size() > 0, "Project should expose GDScript files to inspect")
	var signal_name: String = "minimum_size" + "_changed"

	for script_path in script_paths:
		var source: String = FileAccess.get_file_as_string(script_path)
		assert_false(source.contains("." + signal_name + "("), "%s must call update_minimum_size(), not the %s signal" % [script_path, signal_name])
		assert_false(source.contains("\n\t" + signal_name + "("), "%s must call update_minimum_size(), not the %s signal" % [script_path, signal_name])
		assert_false(source.contains("\n" + signal_name + "("), "%s must call update_minimum_size(), not the %s signal" % [script_path, signal_name])

func _collect_gd_scripts(dir_path: String) -> Array[String]:
	var results: Array[String] = []
	var dir: DirAccess = DirAccess.open(dir_path)
	if dir == null:
		return results

	dir.list_dir_begin()
	var entry_name: String = dir.get_next()
	while entry_name != "":
		var entry_path: String = dir_path.path_join(entry_name)
		if dir.current_is_dir():
			if not entry_name.begins_with("."):
				results.append_array(_collect_gd_scripts(entry_path))
		elif entry_name.ends_with(".gd"):
			results.append(entry_path)
		entry_name = dir.get_next()
	return results
