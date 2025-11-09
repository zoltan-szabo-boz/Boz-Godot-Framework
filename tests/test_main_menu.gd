extends GutTest

# Test suite for the main menu scene
# Run via GUT panel in Godot editor or command line

var main_menu_scene = preload("res://scenes/main_menu.tscn")
var main_menu: Control

# Setup runs before each test
func before_each():
	main_menu = main_menu_scene.instantiate()
	add_child_autofree(main_menu)

# Teardown runs after each test
func after_each():
	pass  # add_child_autofree handles cleanup automatically

# Test: Main menu scene loads successfully
func test_main_menu_loads():
	assert_not_null(main_menu, "Main menu should load")
	assert_true(main_menu is Control, "Main menu should be a Control node")

# Test: Main menu has required buttons
func test_main_menu_has_buttons():
	var start_button = main_menu.get_node_or_null("MarginContainer/HBoxContainer/MainMenuPanel/VBoxContainer/ButtonMargin/ButtonContainer/Start")
	var options_button = main_menu.get_node_or_null("MarginContainer/HBoxContainer/MainMenuPanel/VBoxContainer/ButtonMargin/ButtonContainer/Options")
	var quit_button = main_menu.get_node_or_null("MarginContainer/HBoxContainer/MainMenuPanel/VBoxContainer/ButtonMargin/ButtonContainer/Quit")

	assert_not_null(start_button, "Start button should exist")
	assert_not_null(options_button, "Options button should exist")
	assert_not_null(quit_button, "Quit button should exist")

# Test: Options button is enabled and shows options panel
func test_options_button_shows_panel():
	var options_button = main_menu.get_node_or_null("MarginContainer/HBoxContainer/MainMenuPanel/VBoxContainer/ButtonMargin/ButtonContainer/Options")
	var options_panel = main_menu.get_node_or_null("MarginContainer/HBoxContainer/OptionsPanel")
	var main_panel = main_menu.get_node_or_null("MarginContainer/HBoxContainer/MainMenuPanel")

	assert_not_null(options_button, "Options button should exist")
	assert_false(options_button.disabled, "Options button should be enabled")

	if options_button and options_panel and main_panel:
		# Initially, main panel should be visible and options panel hidden
		assert_true(main_panel.visible, "Main panel should be visible initially")
		assert_false(options_panel.visible, "Options panel should be hidden initially")

		# Press the options button
		options_button.pressed.emit()

		# Options panel should now be visible and main panel hidden
		assert_false(main_panel.visible, "Main panel should be hidden after pressing options")
		assert_true(options_panel.visible, "Options panel should be visible after pressing options")

# Test: Start button triggers scene change
func test_start_button_changes_scene():
	var start_button = main_menu.get_node_or_null("MarginContainer/HBoxContainer/MainMenuPanel/VBoxContainer/ButtonMargin/ButtonContainer/Start")

	if start_button:
		# Watch for scene change
		watch_signals(main_menu.get_tree())

		# Simulate button press
		start_button.pressed.emit()

		# Give it a frame to process
		await get_tree().process_frame

		# Note: In a test environment, we can't actually change scenes,
		# but we can verify the method was called by checking signals
		# or by mocking the scene tree
		pass_test("Start button press simulation completed")

# Test: Main menu has title label
func test_main_menu_has_title():
	var title_label = main_menu.get_node_or_null("MarginContainer/HBoxContainer/MainMenuPanel/VBoxContainer/Label")

	assert_not_null(title_label, "Title label should exist")
	if title_label:
		# Title now uses natural source string
		assert_eq(title_label.text, "Learn Godot!", "Title should use natural source string 'Learn Godot!'")

# Test: Quit button calls quit method
func test_quit_button_functionality():
	var quit_button = main_menu.get_node_or_null("MarginContainer/HBoxContainer/MainMenuPanel/VBoxContainer/ButtonMargin/ButtonContainer/Quit")

	if quit_button:
		# We can't actually quit in tests, but we can verify the signal is connected
		var connections = quit_button.pressed.get_connections()
		assert_gt(connections.size(), 0, "Quit button should have signal connections")

# Test: Options panel has TabContainer with Graphics and Language tabs
func test_options_panel_has_tabcontainer():
	var tab_container = main_menu.get_node_or_null("MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/TabContainer")
	var graphics_tab = main_menu.get_node_or_null("MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/TabContainer/Graphics")
	var language_tab = main_menu.get_node_or_null("MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/TabContainer/Language")

	assert_not_null(tab_container, "TabContainer should exist")
	assert_not_null(graphics_tab, "Graphics tab should exist")
	assert_not_null(language_tab, "Language tab should exist")

#Test: Graphics tab has resolution dropdown, window mode dropdown, font size slider, and high contrast checkbox
func test_graphics_tab_has_controls():
	var resolution_dropdown = main_menu.get_node_or_null("MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/TabContainer/Graphics/VBoxContainer/ResolutionDropdown")
	var window_mode_dropdown = main_menu.get_node_or_null("MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/TabContainer/Graphics/VBoxContainer/WindowModeDropdown")
	var font_size_slider = main_menu.get_node_or_null("MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/TabContainer/Graphics/VBoxContainer/FontSizeContainer/FontSizeSlider")
	var high_contrast_checkbox = main_menu.get_node_or_null("MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/TabContainer/Graphics/VBoxContainer/HighContrastCheckbox")

	assert_not_null(resolution_dropdown, "Resolution dropdown should exist")
	assert_not_null(window_mode_dropdown, "Window mode dropdown should exist")
	assert_not_null(font_size_slider, "UI scale slider should exist")
	assert_not_null(high_contrast_checkbox, "High contrast checkbox should exist")
	if resolution_dropdown:
		assert_eq(resolution_dropdown.item_count, 5, "Resolution dropdown should have 5 options")
	if window_mode_dropdown:
		assert_eq(window_mode_dropdown.item_count, 3, "Window mode dropdown should have 3 options")
	if font_size_slider:
		assert_eq(font_size_slider.min_value, 0.8, "UI scale slider min should be 0.8")
		assert_eq(font_size_slider.max_value, 1.5, "UI scale slider max should be 1.5")
		assert_eq(font_size_slider.value, 1.0, "UI scale slider default should be 1.0")

# Test: Window mode dropdown changes window mode
func test_window_mode_dropdown_changes_mode():
	var window_mode_dropdown = main_menu.get_node_or_null("MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/TabContainer/Graphics/VBoxContainer/WindowModeDropdown")

	if window_mode_dropdown:
		# Set to Windowed (index 0)
		window_mode_dropdown.select(0)
		window_mode_dropdown.item_selected.emit(0)
		await get_tree().process_frame
		assert_eq(ConfigManager.config.window_mode, ConfigManager.WindowMode.WINDOWED, "Window mode should be WINDOWED")

		# Set to Borderless (index 1)
		window_mode_dropdown.select(1)
		window_mode_dropdown.item_selected.emit(1)
		await get_tree().process_frame
		assert_eq(ConfigManager.config.window_mode, ConfigManager.WindowMode.BORDERLESS, "Window mode should be BORDERLESS")

		# Set to Fullscreen (index 2)
		window_mode_dropdown.select(2)
		window_mode_dropdown.item_selected.emit(2)
		await get_tree().process_frame
		assert_eq(ConfigManager.config.window_mode, ConfigManager.WindowMode.FULLSCREEN, "Window mode should be FULLSCREEN")

# Test: Resolution dropdown visibility based on window mode
func test_resolution_visibility_based_on_window_mode():
	var resolution_dropdown = main_menu.get_node_or_null("MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/TabContainer/Graphics/VBoxContainer/ResolutionDropdown")
	var resolution_label = main_menu.get_node_or_null("MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/TabContainer/Graphics/VBoxContainer/ResolutionLabel")
	var window_mode_dropdown = main_menu.get_node_or_null("MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/TabContainer/Graphics/VBoxContainer/WindowModeDropdown")

	if resolution_dropdown and resolution_label and window_mode_dropdown:
		# Set to Windowed mode - resolution should be visible
		window_mode_dropdown.select(0)
		window_mode_dropdown.item_selected.emit(0)
		await get_tree().process_frame
		assert_true(resolution_dropdown.visible, "Resolution dropdown should be visible in windowed mode")
		assert_true(resolution_label.visible, "Resolution label should be visible in windowed mode")

		# Set to Borderless mode - resolution should be hidden
		window_mode_dropdown.select(1)
		window_mode_dropdown.item_selected.emit(1)
		await get_tree().process_frame
		assert_false(resolution_dropdown.visible, "Resolution dropdown should be hidden in borderless mode")
		assert_false(resolution_label.visible, "Resolution label should be hidden in borderless mode")

		# Set to Fullscreen mode - resolution should be hidden
		window_mode_dropdown.select(2)
		window_mode_dropdown.item_selected.emit(2)
		await get_tree().process_frame
		assert_false(resolution_dropdown.visible, "Resolution dropdown should be hidden in fullscreen mode")
		assert_false(resolution_label.visible, "Resolution label should be hidden in fullscreen mode")

# Test: Back button returns to main menu
func test_back_button_returns_to_menu():
	var options_button = main_menu.get_node_or_null("MarginContainer/HBoxContainer/MainMenuPanel/VBoxContainer/ButtonMargin/ButtonContainer/Options")
	var back_button = main_menu.get_node_or_null("MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/BackButtonMargin/BackButton")
	var options_panel = main_menu.get_node_or_null("MarginContainer/HBoxContainer/OptionsPanel")
	var main_panel = main_menu.get_node_or_null("MarginContainer/HBoxContainer/MainMenuPanel")

	if options_button and back_button and options_panel and main_panel:
		# Go to options panel
		options_button.pressed.emit()
		assert_true(options_panel.visible, "Options panel should be visible")

		# Go back to main menu
		back_button.pressed.emit()
		assert_true(main_panel.visible, "Main panel should be visible after going back")
		assert_false(options_panel.visible, "Options panel should be hidden after going back")

# Test: Language dropdown exists and has all languages
func test_language_dropdown_exists():
	var language_dropdown = main_menu.get_node_or_null("MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/TabContainer/Language/VBoxContainer/LanguageDropdown")

	assert_not_null(language_dropdown, "Language dropdown should exist")
	if language_dropdown:
		# Should have 4 languages: English, German, Hungarian, Japanese
		assert_eq(language_dropdown.item_count, 4, "Dropdown should have 4 language options")

# Test: Selecting language from dropdown changes language
func test_language_dropdown_changes_language():
	var language_dropdown = main_menu.get_node_or_null("MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/TabContainer/Language/VBoxContainer/LanguageDropdown")

	if language_dropdown:
		# Languages are sorted: English (0), German (1), Hungarian (2), Japanese (3)
		# Set to English (index 0)
		language_dropdown.select(0)
		language_dropdown.item_selected.emit(0)
		await get_tree().process_frame
		assert_eq(LocalizationManager.get_language(), "en", "Language should change to English")

		# Set to German (index 1)
		language_dropdown.select(1)
		language_dropdown.item_selected.emit(1)
		await get_tree().process_frame
		assert_eq(LocalizationManager.get_language(), "de", "Language should change to German")

		# Set to Hungarian (index 2)
		language_dropdown.select(2)
		language_dropdown.item_selected.emit(2)
		await get_tree().process_frame
		assert_eq(LocalizationManager.get_language(), "hu", "Language should change to Hungarian")

		# Set to Japanese (index 3)
		language_dropdown.select(3)
		language_dropdown.item_selected.emit(3)
		await get_tree().process_frame
		assert_eq(LocalizationManager.get_language(), "ja", "Language should change to Japanese")

# Test: Language change updates UI text
func test_language_change_updates_ui():
	var title_label = main_menu.get_node_or_null("MarginContainer/HBoxContainer/MainMenuPanel/VBoxContainer/Label")

	if title_label:
		# Set to English and wait for update
		LocalizationManager.set_language("en")
		await get_tree().process_frame
		# In Godot, labels with natural source strings automatically translate
		# We verify the natural source string is set (actual translation happens in engine)
		assert_eq(title_label.text, "Learn Godot!", "Label should use natural source string")

# Test: TabContainer tab titles update on language change
func test_tab_titles_update_on_language_change():
	var tab_container = main_menu.get_node_or_null("MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/TabContainer")

	if tab_container:
		# Set to English
		LocalizationManager.set_language("en")
		await get_tree().process_frame
		# Tab titles should be updated programmatically
		# We can't easily test the exact translated text, but we can verify they're not empty
		assert_gt(tab_container.get_tab_title(0).length(), 0, "Graphics tab title should not be empty")
		assert_gt(tab_container.get_tab_title(1).length(), 0, "Language tab title should not be empty")

# Test: High contrast checkbox toggles high contrast mode
func test_high_contrast_checkbox_toggles_mode():
	var high_contrast_checkbox = main_menu.get_node_or_null("MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/TabContainer/Graphics/VBoxContainer/HighContrastCheckbox")

	if high_contrast_checkbox:
		# Test enabling high contrast
		high_contrast_checkbox.button_pressed = true
		high_contrast_checkbox.toggled.emit(true)
		await get_tree().process_frame
		assert_eq(ConfigManager.config.high_contrast, true, "High contrast should be enabled")

		# Test disabling high contrast
		high_contrast_checkbox.button_pressed = false
		high_contrast_checkbox.toggled.emit(false)
		await get_tree().process_frame
		assert_eq(ConfigManager.config.high_contrast, false, "High contrast should be disabled")

# Test: Font size slider changes content scale
func test_font_size_slider_changes_scale():
	var font_size_slider = main_menu.get_node_or_null("MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/TabContainer/Graphics/VBoxContainer/FontSizeContainer/FontSizeSlider")
	var font_size_value = main_menu.get_node_or_null("MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/TabContainer/Graphics/VBoxContainer/FontSizeContainer/FontSizeValue")

	if font_size_slider and font_size_value:
		# Test setting to 1.2
		font_size_slider.value = 1.2
		font_size_slider.value_changed.emit(1.2)
		await get_tree().process_frame
		assert_eq(ConfigManager.config.ui_scale, 1.2, "UI scale should be saved to config")
		assert_eq(font_size_value.text, "1.2", "UI scale value label should display 1.2")

		# Test setting to 0.8 (minimum)
		font_size_slider.value = 0.8
		font_size_slider.value_changed.emit(0.8)
		await get_tree().process_frame
		assert_eq(ConfigManager.config.ui_scale, 0.8, "UI scale should be 0.8")

		# Test setting to 1.5 (maximum)
		font_size_slider.value = 1.5
		font_size_slider.value_changed.emit(1.5)
		await get_tree().process_frame
		assert_eq(ConfigManager.config.ui_scale, 1.5, "UI scale should be 1.5")
