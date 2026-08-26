# tests/test_scaffolding.gd
extends "res://tests/test_base.gd"

## Tests verifying project configuration, window settings, and directory layout.

func test_project_directories_exist() -> void:
	var required_dirs: Array[String] = [
		"res://scenes",
		"res://scripts",
		"res://autoloads",
		"res://assets/fonts",
		"res://assets/words",
		"res://tests"
	]
	for dir_path in required_dirs:
		var dir_exists: bool = DirAccess.dir_exists_absolute(dir_path)
		assert_true(dir_exists, "Required directory '%s' must exist" % dir_path)

func test_display_settings() -> void:
	var width: int = int(ProjectSettings.get_setting("display/window/size/viewport_width", 0))
	var height: int = int(ProjectSettings.get_setting("display/window/size/viewport_height", 0))
	var orientation: int = int(ProjectSettings.get_setting("display/window/handheld/orientation", 0))
	
	assert_eq(width, 720, "Viewport width should be 720 for mobile portrait")
	assert_eq(height, 1280, "Viewport height should be 1280 for mobile portrait")
	assert_eq(orientation, 1, "Handheld orientation should be portrait (1)")

func test_app_settings() -> void:
	var app_name: String = String(ProjectSettings.get_setting("application/config/name", ""))
	assert_eq(app_name, "LetterLogic", "Application name must be LetterLogic")
