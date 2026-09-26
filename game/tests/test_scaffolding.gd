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

func test_rendering_settings() -> void:
	var rendering_method: String = ProjectSettings.get_setting("rendering/renderer/rendering_method", "")
	assert_eq(rendering_method, "gl_compatibility", "Rendering method should be gl_compatibility for Android tearing fix")
	
	var vsync_mode: int = int(ProjectSettings.get_setting("display/window/vsync/vsync_mode", 0))
	assert_eq(vsync_mode, 1, "V-Sync mode should be 1 (Enabled) to prevent screen tearing")

func test_app_settings() -> void:
	var app_name: String = String(ProjectSettings.get_setting("application/config/name", ""))
	assert_eq(app_name, "LetterLogic", "Application name must be LetterLogic")

func test_boot_splash_settings() -> void:
	assert_eq(String(ProjectSettings.get_setting("application/boot_splash/image")), "res://assets/icons/icon.png", "Boot splash image should be configured")
	assert_eq(bool(ProjectSettings.get_setting("application/boot_splash/show_image")), true, "Boot splash image should be shown")
	var bg_color: Color = Color(ProjectSettings.get_setting("application/boot_splash/bg_color", Color.BLACK))
	assert_eq(bg_color, Color(0.0705882, 0.0705882, 0.0705882, 1), "Boot splash bg color should match monochrome palette")
	assert_true(ResourceLoader.exists("res://assets/icons/icon.png"), "Mascot icon asset must exist")

func test_adaptive_icon_settings() -> void:
	assert_true(ResourceLoader.exists("res://assets/icons/icon_foreground.png"), "Adaptive icon foreground asset must exist")
	assert_true(ResourceLoader.exists("res://assets/icons/icon_background.png"), "Adaptive icon background asset must exist")
	var config: ConfigFile = ConfigFile.new()
	var err: Error = config.load("res://export_presets.cfg")
	assert_eq(err, OK, "export_presets.cfg should load successfully")
	if err == OK:
		assert_eq(String(config.get_value("preset.0.options", "launcher_icons/adaptive_foreground_432x432", "")), "res://assets/icons/icon_foreground.png", "Adaptive foreground icon must be configured")
		assert_eq(String(config.get_value("preset.0.options", "launcher_icons/adaptive_background_432x432", "")), "res://assets/icons/icon_background.png", "Adaptive background icon must be configured")

func test_font_fallback_configuration() -> void:
	assert_true(ResourceLoader.exists("res://assets/fonts/NotoColorEmoji.ttf"), "NotoColorEmoji font asset must exist")
	assert_true(ResourceLoader.exists("res://assets/fonts/NotoSansSymbols-Regular.ttf"), "NotoSansSymbols font asset must exist")
	
	var emoji_font: Font = load("res://assets/fonts/NotoColorEmoji.ttf") as Font
	assert_true(emoji_font != null, "NotoColorEmoji font should load successfully")
	assert_true(emoji_font.has_char(0x1F7E9), "NotoColorEmoji should include green square emoji")
	
	var symbols_font: Font = load("res://assets/fonts/NotoSansSymbols-Regular.ttf") as Font
	assert_true(symbols_font != null, "NotoSansSymbols font should load successfully")
	assert_true(symbols_font.has_char(0x232B), "NotoSansSymbols should include backspace symbol")
	assert_true(symbols_font.has_char(0x2715), "NotoSansSymbols should include cross symbol")

	var theme_res: Theme = load("res://assets/theme/letter_logic_theme.tres") as Theme
	assert_true(theme_res != null, "Custom project theme should load successfully")
	assert_true(theme_res.default_font == null, "Default font should NOT be configured globally to prevent metric breakages")
	
	var fallback_res: SystemFont = load("res://assets/theme/fallback_font.tres") as SystemFont
	assert_true(fallback_res != null, "Fallback font resource should load successfully")
	assert_true(fallback_res.fallbacks.size() > 0, "Fallback font should have fallback fonts configured")


