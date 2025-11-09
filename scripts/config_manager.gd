extends Node

const CONFIG_FILE = "user://config.cfg"

# Window mode enum
enum WindowMode {
	WINDOWED = 0,        # Traditional windowed mode with resolution control
	BORDERLESS = 1,      # Borderless fullscreen (recommended for PC gaming)
	FULLSCREEN = 2       # Exclusive fullscreen mode
}

var config = {
	"resolution": Vector2i(1152, 648),
	"window_mode": WindowMode.BORDERLESS,  # Default to borderless (modern PC standard)
	"ui_scale": 1.0
}

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
	# Only apply resolution in windowed mode
	if config.window_mode == WindowMode.WINDOWED:
		DisplayServer.window_set_size(config.resolution)

		var screen_size = DisplayServer.screen_get_size()
		var window_pos = (screen_size - config.resolution) / 2
		DisplayServer.window_set_position(window_pos)

func apply_window_mode():
	match config.window_mode:
		WindowMode.WINDOWED:
			# Traditional windowed mode with custom resolution
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			apply_resolution()
			print("ConfigManager: Applied WINDOWED mode")

		WindowMode.BORDERLESS:
			# Borderless fullscreen - uses native resolution, fast alt-tab
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			# Set to native screen size
			var screen_size = DisplayServer.screen_get_size()
			DisplayServer.window_set_size(screen_size)
			DisplayServer.window_set_position(Vector2i(0, 0))
			print("ConfigManager: Applied BORDERLESS mode at %dx%d" % [screen_size.x, screen_size.y])

		WindowMode.FULLSCREEN:
			# Exclusive fullscreen mode
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			print("ConfigManager: Applied FULLSCREEN mode")

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

func is_resolution_applicable() -> bool:
	# Resolution selection only applies in windowed mode
	return config.window_mode == WindowMode.WINDOWED
