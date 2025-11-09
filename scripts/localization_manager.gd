extends Node

## LocalizationManager - Translation and Language Management
##
## Provides centralized language switching and persists user language preference.
## Uses Godot's built-in translation system (CSV translation files).
##
## Key Features:
## - Automatic language detection from OS
## - Language switching with TranslationServer
## - Persists language preference via FileManager
## - Emits events via EventBus for cross-system communication
##
## Usage:
## - Call LocalizationManager.set_language("en") to switch language
## - Use tr("KEY") in scripts for dynamic text translation
## - Set text properties to keys in scenes for auto-translation
## - Subscribe to language changes: EventBus.subscribe("language_changed", callback)
##
## Available Languages:
## - en: English
## - de: German (Deutsch)
## - hu: Hungarian (Magyar)
## - ja: Japanese (日本語)
##
## EventBus Events:
## - "language_changed" - Emitted when language changes (payload: {"locale": String})

const CONFIG_FILE = "user://config.cfg"

# Available languages in the game
# Sorted: English first, then alphabetically by name
# name: Native language name (shown in dropdown)
# translation_key: Key used to get translated name in other languages
var available_languages = [
	{"code": "en", "name": "English", "translation_key": "English"},
	{"code": "de", "name": "Deutsch", "translation_key": "German"},
	{"code": "hu", "name": "Magyar", "translation_key": "Hungarian"},
	{"code": "ja", "name": "日本語", "translation_key": "Japanese"}
]

var current_language: String = "en"

func _ready():
	load_language_preference()
	apply_language()

func load_language_preference():
	# Load language from config via FileManager
	var config_data = FileManager.read_config_file(CONFIG_FILE)

	if config_data.has("localization"):
		current_language = config_data.localization.get("language", _detect_system_language())
	else:
		# No saved preference, detect from system
		current_language = _detect_system_language()

	print("LocalizationManager: Loaded language preference: %s" % current_language)

func save_language_preference():
	# Load existing config data to preserve other settings
	var config_data = FileManager.read_config_file(CONFIG_FILE)

	# Add or update localization section
	if not config_data.has("localization"):
		config_data["localization"] = {}

	config_data.localization["language"] = current_language

	# Queue write through FileManager
	FileManager.queue_config_write(CONFIG_FILE, config_data)
	FileManager.flush_file(CONFIG_FILE)

	print("LocalizationManager: Saved language preference: %s" % current_language)

func _detect_system_language() -> String:
	# Get system locale and map to available languages
	var system_locale = OS.get_locale()
	var language_code = system_locale.substr(0, 2)

	# Check if the system language is available
	for lang in available_languages:
		if lang.code == language_code:
			print("LocalizationManager: Detected system language: %s" % language_code)
			return language_code

	# Default to English if system language not available
	print("LocalizationManager: System language '%s' not available, defaulting to English" % language_code)
	return "en"

func apply_language():
	# Apply the current language using TranslationServer
	TranslationServer.set_locale(current_language)
	print("LocalizationManager: Applied language: %s" % current_language)

func set_language(locale: String):
	# Validate locale
	var is_valid = false
	for lang in available_languages:
		if lang.code == locale:
			is_valid = true
			break

	if not is_valid:
		print("LocalizationManager: Invalid locale '%s'" % locale)
		return

	# Update language
	current_language = locale
	apply_language()
	save_language_preference()

	# Emit via EventBus for cross-system communication
	EventBus.emit("language_changed", {"locale": locale})

	print("LocalizationManager: Language changed to %s" % locale)

func get_language() -> String:
	return current_language

func get_available_languages() -> Array:
	return available_languages

func get_language_name(locale: String) -> String:
	for lang in available_languages:
		if lang.code == locale:
			return lang.name
	return "Unknown"
