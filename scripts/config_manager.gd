extends Node

const CONFIG_FILE = "user://config.cfg"

# Preload theme classes for conversion
const ThemeColors = preload("res://scripts/theme/theme_colors.gd")
const ThemeConverter = preload("res://scripts/theme/theme_converter.gd")

# Window mode enum
enum WindowMode {
	WINDOWED = 0,        # Traditional windowed mode with resolution control
	BORDERLESS = 1,      # Borderless fullscreen (recommended for PC gaming)
	FULLSCREEN = 2       # Exclusive fullscreen mode
}

var config = {
	"resolution": Vector2i(1152, 648),
	"window_mode": WindowMode.BORDERLESS,  # Default to borderless (modern PC standard)
	"ui_scale": 1.0,
	"high_contrast": false  # Accessibility: high contrast theme for better visibility
}

# Theme paths - developers can override these
var base_theme_path: String = "res://themes/base_theme.tres"
var high_contrast_theme_path: String = ""  # Empty = auto-convert base theme

# Cached themes
var _base_theme: Theme = null
var _high_contrast_theme: Theme = null

var available_resolutions = [
	Vector2i(1920, 1080),
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1366, 768),
	Vector2i(1024, 768)
]

func _ready():
	load_config()
	apply_window_mode()
	# Apply UI scale immediately
	apply_ui_scale()
	# Load themes
	_load_themes()
	# Apply high contrast theme if enabled
	apply_high_contrast_theme()

func _notification(what):
	# Ensure config is saved on exit
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# Force immediate flush of any pending config writes
		FileManager.flush_file(CONFIG_FILE)

func save_config(flush_immediately: bool = true):
	# Prepare config data in FileManager's expected format
	var config_data = {
		"display": {
			"resolution_x": config.resolution.x,
			"resolution_y": config.resolution.y,
			"window_mode": config.window_mode,
			"ui_scale": config.ui_scale
		},
		"accessibility": {
			"high_contrast": config.high_contrast
		}
	}

	# Queue the write through FileManager
	FileManager.queue_config_write(CONFIG_FILE, config_data)

	# Optionally flush immediately for critical settings
	# FileManager will auto-flush periodically otherwise
	if flush_immediately:
		FileManager.flush_file(CONFIG_FILE)

func load_config():
	# Load config through FileManager
	var config_data = FileManager.read_config_file(CONFIG_FILE)

	if config_data.is_empty():
		print("No config file found, using defaults")
		return

	# Extract display settings with defaults
	if config_data.has("display"):
		var display = config_data.display
		var res_x = display.get("resolution_x", config.resolution.x)
		var res_y = display.get("resolution_y", config.resolution.y)
		config.resolution = Vector2i(res_x, res_y)

		# Load window_mode with backward compatibility for old fullscreen bool
		if display.has("window_mode"):
			config.window_mode = display.get("window_mode", config.window_mode)
		elif display.has("fullscreen"):
			# Convert old fullscreen bool to window_mode enum
			config.window_mode = WindowMode.FULLSCREEN if display.get("fullscreen") else WindowMode.WINDOWED

		# Support loading old font_scale config and converting to ui_scale
		config.ui_scale = display.get("ui_scale", display.get("font_scale", config.ui_scale))

	# Load accessibility settings
	if config_data.has("accessibility"):
		var accessibility = config_data.accessibility
		config.high_contrast = accessibility.get("high_contrast", config.high_contrast)

func set_resolution(resolution: Vector2i):
	config.resolution = resolution
	apply_resolution()
	save_config()

func set_window_mode(mode: WindowMode):
	config.window_mode = mode
	apply_window_mode()
	save_config()
	print("ConfigManager: Window mode changed to %d" % mode)

func set_ui_scale(scale: float):
	# Clamp to reasonable limits (0.8 to 1.5 for better accessibility)
	config.ui_scale = clampf(scale, 0.8, 1.5)
	# Don't flush immediately - let FileManager auto-flush periodically
	# This prevents freezing when dragging the slider
	save_config(false)
	# Apply UI scale immediately
	apply_ui_scale()
	# Emit event via EventBus for UI to react (for updating UI elements like the slider value)
	EventBus.emit("ui_scale_changed", {"scale": config.ui_scale})

func apply_resolution():
	# In windowed mode, use 1:1 pixel mapping (no scaling) for sharp text
	# In borderless/fullscreen modes, use viewport scaling to fit display
	if config.window_mode == WindowMode.WINDOWED:
		# Disable content scaling - render at window size directly (1:1 pixels)
		get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
		get_tree().root.content_scale_size = Vector2i(0, 0)

		# Set window size to desired resolution
		DisplayServer.window_set_size(config.resolution)

		# Center window on screen
		var screen_size = DisplayServer.screen_get_size()
		var window_pos = (screen_size - config.resolution) / 2
		DisplayServer.window_set_position(window_pos)

		print("ConfigManager: Applied render resolution: %dx%d (1:1 pixels, no scaling)" % [config.resolution.x, config.resolution.y])
	else:
		# Use viewport scaling for borderless/fullscreen modes
		get_tree().root.content_scale_size = config.resolution
		get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
		get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
		print("ConfigManager: Applied render resolution: %dx%d (with viewport scaling)" % [config.resolution.x, config.resolution.y])

func apply_window_mode():
	# First, set the window mode and flags
	match config.window_mode:
		WindowMode.WINDOWED:
			# Traditional windowed mode with custom resolution
			# Remove borderless flag FIRST
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)

			# Force a mode transition to refresh window decorations
			# (needed when coming from borderless which is also WINDOW_MODE_WINDOWED)
			# Temporarily switch to maximized then back to windowed to force refresh
			var current_mode = DisplayServer.window_get_mode()
			if current_mode == DisplayServer.WINDOW_MODE_WINDOWED:
				# Already in windowed mode (from borderless), force refresh via mode toggle
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			print("ConfigManager: Applied WINDOWED mode")

		WindowMode.BORDERLESS:
			# Borderless fullscreen - display at native resolution, render at configured resolution
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			# Set display to native screen size
			var screen_size = DisplayServer.screen_get_size()
			DisplayServer.window_set_size(screen_size)
			DisplayServer.window_set_position(Vector2i(0, 0))
			print("ConfigManager: Applied BORDERLESS mode - display: %dx%d" % [screen_size.x, screen_size.y])

		WindowMode.FULLSCREEN:
			# Exclusive fullscreen mode - render at configured resolution
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			print("ConfigManager: Applied FULLSCREEN mode")

	# Always apply resolution after window mode changes to ensure proper scaling/sizing
	apply_resolution()

func apply_ui_scale():
	# Apply UI scaling using Godot's built-in content scale factor
	# This scales the entire UI tree proportionally, including text, buttons, icons, and spacing
	get_tree().root.content_scale_factor = config.ui_scale
	print("ConfigManager: Applied UI scale: %.1fx" % config.ui_scale)

func get_resolution_index() -> int:
	for i in range(available_resolutions.size()):
		if available_resolutions[i] == config.resolution:
			return i
	return 0

func set_high_contrast(enabled: bool):
	config.high_contrast = enabled
	save_config()
	apply_high_contrast_theme()
	# Emit event via EventBus for UI to react
	EventBus.emit("high_contrast_changed", {"enabled": config.high_contrast})
	print("ConfigManager: High contrast mode %s" % ("enabled" if enabled else "disabled"))

func _load_themes():
	# Load base theme
	if ResourceLoader.exists(base_theme_path):
		_base_theme = load(base_theme_path)
		print("ConfigManager: Loaded base theme from %s" % base_theme_path)
	else:
		print("ConfigManager: Warning - base theme not found at %s" % base_theme_path)

	# Load or generate high contrast theme
	if high_contrast_theme_path != "" and ResourceLoader.exists(high_contrast_theme_path):
		# Developer provided custom high contrast theme
		_high_contrast_theme = load(high_contrast_theme_path)
		print("ConfigManager: Loaded custom high contrast theme from %s" % high_contrast_theme_path)
	elif _base_theme != null:
		# Auto-convert base theme to high contrast
		_high_contrast_theme = _create_high_contrast_theme_from_base()
		print("ConfigManager: Auto-generated high contrast theme from base theme")
	else:
		print("ConfigManager: Warning - cannot create high contrast theme, no base theme available")

func _create_high_contrast_theme_from_base() -> Theme:
	# Create a new theme based on the base theme with high contrast colors
	var hc_theme := Theme.new()
	var converter := ThemeConverter.new()

	# Copy the base theme structure
	if _base_theme != null:
		# Note: We can't directly clone Theme, so we'll create a new one
		# and apply high contrast colors to common controls

		# Convert key colors
		var hc_text := converter.to_high_contrast_foreground(ThemeColors.TEXT_PRIMARY, false)
		var hc_text_disabled := converter.to_high_contrast_foreground(ThemeColors.TEXT_DISABLED, false)
		var hc_bg_dark := converter.to_high_contrast_background(ThemeColors.BG_DARK, false)
		var hc_primary := converter.to_high_contrast_accent(ThemeColors.PRIMARY)

		# Apply to Button
		hc_theme.set_color("font_color", "Button", hc_text)
		hc_theme.set_color("font_hover_color", "Button", hc_text)
		hc_theme.set_color("font_pressed_color", "Button", hc_text)
		hc_theme.set_color("font_disabled_color", "Button", hc_text_disabled)

		# Apply to Label
		hc_theme.set_color("font_color", "Label", hc_text)

		# Apply to CheckButton
		hc_theme.set_color("font_color", "CheckButton", hc_text)
		hc_theme.set_color("font_hover_color", "CheckButton", hc_text)
		hc_theme.set_color("font_pressed_color", "CheckButton", hc_text)

		# Apply to OptionButton
		hc_theme.set_color("font_color", "OptionButton", hc_text)
		hc_theme.set_color("font_hover_color", "OptionButton", hc_text)

		# Create high contrast StyleBoxFlat for panels
		var panel_style := StyleBoxFlat.new()
		panel_style.bg_color = hc_bg_dark
		panel_style.border_color = Color.WHITE
		panel_style.border_width_left = 3
		panel_style.border_width_top = 3
		panel_style.border_width_right = 3
		panel_style.border_width_bottom = 3
		panel_style.corner_radius_top_left = 4
		panel_style.corner_radius_top_right = 4
		panel_style.corner_radius_bottom_left = 4
		panel_style.corner_radius_bottom_right = 4
		hc_theme.set_stylebox("panel", "Panel", panel_style)

		# Create high contrast button styles
		var button_normal := StyleBoxFlat.new()
		button_normal.bg_color = hc_bg_dark
		button_normal.border_color = Color.WHITE
		button_normal.border_width_left = 3
		button_normal.border_width_top = 3
		button_normal.border_width_right = 3
		button_normal.border_width_bottom = 3
		button_normal.corner_radius_top_left = 4
		button_normal.corner_radius_top_right = 4
		button_normal.corner_radius_bottom_left = 4
		button_normal.corner_radius_bottom_right = 4
		button_normal.content_margin_left = 16
		button_normal.content_margin_top = 8
		button_normal.content_margin_right = 16
		button_normal.content_margin_bottom = 8

		var button_hover := button_normal.duplicate()
		button_hover.bg_color = ThemeColors.lighten(hc_bg_dark, 0.3)
		button_hover.border_color = hc_primary

		var button_pressed := button_normal.duplicate()
		button_pressed.bg_color = hc_primary

		hc_theme.set_stylebox("normal", "Button", button_normal)
		hc_theme.set_stylebox("hover", "Button", button_hover)
		hc_theme.set_stylebox("pressed", "Button", button_pressed)
		hc_theme.set_stylebox("focus", "Button", button_hover)

		print("ConfigManager: High contrast theme created")
		print("  - Text: %s (contrast: %.1f:1)" % [hc_text, converter.calculate_contrast_ratio(hc_text, hc_bg_dark)])
		print("  - Primary: %s (contrast: %.1f:1)" % [hc_primary, converter.calculate_contrast_ratio(hc_primary, hc_bg_dark)])

	return hc_theme

func apply_high_contrast_theme():
	# Apply or remove high contrast theme to the entire application
	var root := get_tree().root

	if config.high_contrast:
		if _high_contrast_theme != null:
			print("ConfigManager: Applying high contrast theme")
			root.set_theme(_high_contrast_theme)
		else:
			print("ConfigManager: Warning - high contrast theme not available")
	else:
		print("ConfigManager: Restoring base theme")
		# Restore base theme
		if _base_theme != null:
			root.set_theme(_base_theme)
		else:
			# Fall back to project default theme
			root.set_theme(null)
