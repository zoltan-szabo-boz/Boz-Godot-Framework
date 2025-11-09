extends Control

@onready var main_menu_panel = $MarginContainer/HBoxContainer/MainMenuPanel
@onready var options_panel = $MarginContainer/HBoxContainer/OptionsPanel
@onready var tab_container = $MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/TabContainer
@onready var resolution_dropdown = $MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/TabContainer/Graphics/VBoxContainer/ResolutionDropdown
@onready var fullscreen_check = $MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/TabContainer/Graphics/VBoxContainer/Fullscreen
@onready var font_size_slider = $MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/TabContainer/Graphics/VBoxContainer/FontSizeContainer/FontSizeSlider
@onready var font_size_value = $MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/TabContainer/Graphics/VBoxContainer/FontSizeContainer/FontSizeValue
@onready var language_dropdown = $MarginContainer/HBoxContainer/OptionsPanel/VBoxContainer/TabContainer/Language/VBoxContainer/LanguageDropdown

func _ready():
	# Initialize fullscreen checkbox state from config
	fullscreen_check.button_pressed = ConfigManager.config.fullscreen

	# Initialize font size slider from config
	font_size_slider.value = ConfigManager.config.font_scale
	_update_font_size_label(ConfigManager.config.font_scale)

	# Populate resolution dropdown
	_populate_resolution_dropdown()

	# Populate language dropdown
	_populate_language_dropdown()

	# Update tab titles for localization
	_update_tab_titles()

	# Subscribe to language change events via EventBus
	EventBus.subscribe("language_changed", _on_language_changed)

	# Subscribe to font scale change events
	EventBus.subscribe("font_scale_changed", _on_font_scale_changed)

	# Apply initial font scale (ConfigManager also does this, but we ensure it's current)
	ConfigManager.apply_font_scale()

	_register_tooltips()

func _exit_tree():
	# Unsubscribe from EventBus when leaving tree
	EventBus.unsubscribe("language_changed", _on_language_changed)
	EventBus.unsubscribe("font_scale_changed", _on_font_scale_changed)

func _register_tooltips():
	# Dynamic tooltip with current time for demonstration
	TooltipManager.register_tooltip(
		$MarginContainer/HBoxContainer/MainMenuPanel/VBoxContainer/ButtonMargin/ButtonContainer/Start,
		func(): return tr("Start the game") + "\n" + TimeUtils.format_current_time()
	)

	TooltipManager.register_tooltip(
		$MarginContainer/HBoxContainer/MainMenuPanel/VBoxContainer/ButtonMargin/ButtonContainer/Options,
		func(): return tr("Change the options")
	)

	TooltipManager.register_tooltip(
		$MarginContainer/HBoxContainer/MainMenuPanel/VBoxContainer/ButtonMargin/ButtonContainer/Quit,
		func(): return tr("Exit the game")
	)

func _on_quit_pressed():
	# Quits the application immediately
	get_tree().quit()

func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_options_pressed():
	# Switch to options panel
	main_menu_panel.hide()
	options_panel.show()

func _on_back_to_menu_pressed():
	# Switch back to main menu panel
	options_panel.hide()
	main_menu_panel.show()

func _populate_resolution_dropdown():
	# Clear existing items
	resolution_dropdown.clear()

	# Available resolutions (width, height, translation_key)
	var resolutions = [
		[1920, 1080, "1920 x 1080 (Full HD)"],
		[1600, 900, "1600 x 900 (HD+)"],
		[1366, 768, "1366 x 768"],
		[1280, 720, "1280 x 720 (HD)"],
		[1024, 768, "1024 x 768"]
	]

	# Get current resolution
	var current_res = ConfigManager.config.resolution
	var current_index = 0

	# Add all resolutions to dropdown
	for i in range(resolutions.size()):
		var res = resolutions[i]
		resolution_dropdown.add_item(tr(res[2]), i)

		# Check if this is the current resolution
		if current_res.x == res[0] and current_res.y == res[1]:
			current_index = i

	# Select the current resolution
	resolution_dropdown.select(current_index)

func _on_resolution_dropdown_selected(index: int):
	# Resolution mappings matching the dropdown order
	var resolutions = [
		Vector2i(1920, 1080),
		Vector2i(1600, 900),
		Vector2i(1366, 768),
		Vector2i(1280, 720),
		Vector2i(1024, 768)
	]

	# Get the selected resolution
	var selected_res = resolutions[index]
	print(tr("Changing resolution to %dx%d") % [selected_res.x, selected_res.y])

	# If in fullscreen mode, switch to windowed first
	if ConfigManager.config.fullscreen:
		ConfigManager.set_fullscreen(false)
		fullscreen_check.button_pressed = false

	# Set the window size through ConfigManager
	ConfigManager.set_resolution(selected_res)

func _on_fullscreen_toggled(toggled_on: bool):
	# Toggle fullscreen mode and save to config
	ConfigManager.set_fullscreen(toggled_on)
	var message_key = "Fullscreen enabled" if toggled_on else "Fullscreen disabled"
	print(tr(message_key))

func _populate_language_dropdown():
	# Clear existing items
	language_dropdown.clear()

	# Add all available languages
	var current_language = LocalizationManager.get_language()
	var current_index = 0

	for i in range(LocalizationManager.available_languages.size()):
		var lang = LocalizationManager.available_languages[i]
		var display_name = ""

		if lang.code == current_language:
			# For the currently selected language, only show native name
			# e.g., "Magyar" when Hungarian is selected
			display_name = lang.name
		else:
			# For other languages, show translated name with native in parenthesis
			# e.g., "Angol (English)" in Hungarian, or "German (Deutsch)" in English
			var translated_name = tr(lang.translation_key)
			if translated_name != lang.name:
				display_name = translated_name + " (" + lang.name + ")"

		language_dropdown.add_item(display_name, i)

		# Track the current language index
		if lang.code == current_language:
			current_index = i

	# Set the dropdown to current language
	language_dropdown.select(current_index)

func _update_tab_titles():
	# Update TabContainer tab titles with translated text
	tab_container.set_tab_title(0, tr("Graphics"))
	tab_container.set_tab_title(1, tr("Language"))

func _on_language_changed(_data: Dictionary):
	# Repopulate dropdown to update translated language names
	# _data contains: {"locale": String} - required by EventBus but not used here
	_populate_language_dropdown()

	# Update tab titles to reflect new language
	_update_tab_titles()

	# Update resolution dropdown to reflect new language
	_populate_resolution_dropdown()

func _on_language_dropdown_selected(index: int):
	# Get the language code from the selected index
	var lang = LocalizationManager.available_languages[index]
	LocalizationManager.set_language(lang.code)
	print("Language changed to: %s" % lang.code)

func _on_font_size_slider_value_changed(value: float):
	# Update the label to show current value
	_update_font_size_label(value)

	# Save to config and trigger EventBus notification
	ConfigManager.set_font_scale(value)

func _update_font_size_label(value: float):
	# Format value to 1 decimal place
	font_size_value.text = "%.1f" % value

func _on_font_scale_changed(_data: Dictionary):
	# Font scale is now applied automatically by ConfigManager
	# This callback is kept for potential future UI updates
	# _data contains: {"scale": float}
	pass
