extends GutTest

# Test suite for LocalizationManager
# Tests language switching, persistence, and translation functionality

var initial_locale: String

# Test callback state for EventBus tests
var _event_received: bool = false
var _received_locale: String = ""
var _received_data: Dictionary = {}

# Setup runs before each test
func before_each():
	# Store initial locale to restore after tests
	initial_locale = LocalizationManager.current_language

	# Reset EventBus test state
	_event_received = false
	_received_locale = ""
	_received_data = {}

# Teardown runs after each test
func after_each():
	# Restore initial locale
	LocalizationManager.set_language(initial_locale)

	# Clean up EventBus subscriptions
	EventBus.unsubscribe("language_changed", _on_language_changed_test)

# Callback for EventBus tests
func _on_language_changed_test(data: Dictionary):
	_event_received = true
	_received_locale = data.get("locale", "")
	_received_data = data

# Test: LocalizationManager is loaded as singleton
func test_localization_manager_exists():
	assert_not_null(LocalizationManager, "LocalizationManager should exist as singleton")

# Test: Available languages are defined
func test_available_languages_defined():
	var languages = LocalizationManager.get_available_languages()

	assert_not_null(languages, "Available languages should be defined")
	assert_gt(languages.size(), 0, "Should have at least one language")

# Test: Language codes are correct
func test_language_codes():
	var languages = LocalizationManager.get_available_languages()
	var codes = []

	for lang in languages:
		codes.append(lang.code)

	assert_true(codes.has("en"), "Should have English (en)")
	assert_true(codes.has("de"), "Should have German (de)")
	assert_true(codes.has("hu"), "Should have Hungarian (hu)")
	assert_true(codes.has("ja"), "Should have Japanese (ja)")

# Test: Current language is set
func test_current_language_is_set():
	var current = LocalizationManager.get_language()

	assert_not_null(current, "Current language should be set")
	assert_true(current in ["en", "de", "hu", "ja"], "Current language should be 'en', 'de', 'hu', or 'ja'")

# Test: Change language to English
func test_change_language_to_english():
	LocalizationManager.set_language("en")

	assert_eq(LocalizationManager.get_language(), "en", "Language should be set to English")
	assert_eq(TranslationServer.get_locale(), "en", "TranslationServer locale should be 'en'")

# Test: Change language to Hungarian
func test_change_language_to_hungarian():
	LocalizationManager.set_language("hu")

	assert_eq(LocalizationManager.get_language(), "hu", "Language should be set to Hungarian")
	assert_eq(TranslationServer.get_locale(), "hu", "TranslationServer locale should be 'hu'")

# Test: Invalid language code is rejected
# Note: This test validates that setting an invalid language doesn't change the current language
# The warning logged by LocalizationManager is expected behavior and is intentionally not checked here
func test_invalid_language_rejected():
	# Set to a known valid language first
	LocalizationManager.set_language("en")
	var before_invalid = LocalizationManager.get_language()

	# Try to set invalid language - this will log a warning (which is expected)
	LocalizationManager.set_language("invalid")

	# Language should remain unchanged
	assert_eq(LocalizationManager.get_language(), before_invalid, "Invalid language should not change current language")

# Test: Language changed event is emitted via EventBus
func test_language_changed_event():
	# Subscribe to EventBus event using instance method
	EventBus.subscribe("language_changed", _on_language_changed_test)

	# Change language (EventBus emits synchronously)
	LocalizationManager.set_language("en")

	# Verify event was received
	assert_true(_event_received, "language_changed event should be emitted via EventBus")
	assert_eq(_received_locale, "en", "Event should contain correct locale 'en'")

# Test: Language changed event contains correct payload structure
func test_language_changed_event_payload():
	# Subscribe to EventBus event using instance method
	EventBus.subscribe("language_changed", _on_language_changed_test)

	# Change language (EventBus emits synchronously)
	LocalizationManager.set_language("hu")

	# Verify payload structure
	assert_true(_received_data.has("locale"), "Event payload should have 'locale' key")
	assert_eq(_received_data.locale, "hu", "Event payload locale should be 'hu'")

# Test: Translation works for English
func test_translation_english():
	LocalizationManager.set_language("en")

	var translated = tr("Learn Godot!")
	assert_eq(translated, "Learn Godot!", "'Learn Godot!' should translate to 'Learn Godot!' in English")

	var button = tr("Start Game")
	assert_eq(button, "Start Game", "'Start Game' should translate to 'Start Game' in English")

# Test: Translation works for German
func test_translation_german():
	LocalizationManager.set_language("de")

	var translated = tr("Learn Godot!")
	assert_eq(translated, "Lerne Godot!", "'Learn Godot!' should translate to 'Lerne Godot!' in German")

	var button = tr("Start Game")
	assert_eq(button, "Spiel starten", "'Start Game' should translate to 'Spiel starten' in German")

# Test: Translation works for Hungarian
func test_translation_hungarian():
	LocalizationManager.set_language("hu")

	var translated = tr("Learn Godot!")
	assert_eq(translated, "Tanuld meg a Godót!", "'Learn Godot!' should translate to 'Tanuld meg a Godót!' in Hungarian")

	var button = tr("Start Game")
	assert_eq(button, "Játék indítása", "'Start Game' should translate to 'Játék indítása' in Hungarian")

# Test: Translation works for Japanese
func test_translation_japanese():
	LocalizationManager.set_language("ja")

	var translated = tr("Learn Godot!")
	assert_eq(translated, "Godotを学ぼう！", "'Learn Godot!' should translate to 'Godotを学ぼう！' in Japanese")

	var button = tr("Start Game")
	assert_eq(button, "ゲーム開始", "'Start Game' should translate to 'ゲーム開始' in Japanese")

# Test: Translation with string formatting works
func test_translation_with_formatting():
	LocalizationManager.set_language("en")

	var message = tr("Changing resolution to %dx%d") % [1920, 1080]
	assert_eq(message, "Changing resolution to 1920x1080", "String formatting with tr() should work")

# Test: Missing translation key returns key itself
func test_missing_translation_key():
	var translated = tr("NONEXISTENT_KEY")
	assert_eq(translated, "NONEXISTENT_KEY", "Missing translation key should return the key itself")

# Test: Get language name by code
func test_get_language_name():
	var english_name = LocalizationManager.get_language_name("en")
	assert_eq(english_name, "English", "English language name should be 'English'")

	var german_name = LocalizationManager.get_language_name("de")
	assert_eq(german_name, "Deutsch", "German language name should be 'Deutsch'")

	var hungarian_name = LocalizationManager.get_language_name("hu")
	assert_eq(hungarian_name, "Magyar", "Hungarian language name should be 'Magyar'")

	var japanese_name = LocalizationManager.get_language_name("ja")
	assert_eq(japanese_name, "日本語", "Japanese language name should be '日本語'")

# Test: Get language name for unknown code
func test_get_language_name_unknown():
	var unknown_name = LocalizationManager.get_language_name("unknown")
	assert_eq(unknown_name, "Unknown", "Unknown language code should return 'Unknown'")

# Test: Language persistence (saved to config)
func test_language_persistence():
	# Change language (this automatically saves to config)
	LocalizationManager.set_language("hu")

	# Wait a frame for file operations to complete
	await get_tree().process_frame

	# Read config directly to verify (file was already flushed by set_language)
	var config_data = FileManager.read_config_file("user://config.cfg")

	assert_true(config_data.has("localization"), "Config should have localization section")
	if config_data.has("localization"):
		assert_eq(config_data.localization.language, "hu", "Saved language should be 'hu'")

# Test: Switch language multiple times
func test_multiple_language_switches():
	LocalizationManager.set_language("en")
	assert_eq(LocalizationManager.get_language(), "en", "Should switch to English")

	LocalizationManager.set_language("hu")
	assert_eq(LocalizationManager.get_language(), "hu", "Should switch to Hungarian")

	LocalizationManager.set_language("en")
	assert_eq(LocalizationManager.get_language(), "en", "Should switch back to English")

# Test: All translation keys exist in all languages
func test_all_keys_exist_in_both_languages():
	var test_keys = [
		"Learn Godot!",
		"Start Game",
		"Options",
		"Quit",
		"Resolution",
		"Fullscreen",
		"Language"
	]

	# Test English (source strings should equal themselves)
	LocalizationManager.set_language("en")
	for key in test_keys:
		var translated = tr(key)
		assert_eq(translated, key, "Key '%s' should translate to itself in English" % key)

	# Test Hungarian (should translate to Hungarian)
	LocalizationManager.set_language("hu")
	for key in test_keys:
		var translated = tr(key)
		assert_ne(translated, key, "Key '%s' should have Hungarian translation" % key)
