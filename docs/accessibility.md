# Accessibility Guide

This document describes the accessibility features implemented in the Boz Godot Framework and provides best practices for maintaining and extending these features.

## Overview

The framework implements comprehensive accessibility features to ensure the game is playable by users with various visual impairments and different display preferences.

## Implemented Features

### 1. UI Scale (0.8x - 1.5x)

**Purpose:** Allows users to scale the entire interface proportionally for better readability.

**Implementation:**
- Uses Godot's `content_scale_factor` property on the root viewport
- Scales everything together: text, buttons, icons, spacing, layouts
- Range: 0.8x to 1.5x (limited to prevent extreme distortion)
- Persisted in user config file

**Usage in ConfigManager:**
```gdscript
ConfigManager.set_ui_scale(1.2)  # Set to 120%
var current_scale = ConfigManager.config.ui_scale  # Get current scale
```

**Benefits:**
- Users with visual impairments can make UI elements larger
- Maintains visual consistency by scaling everything proportionally
- No layout breaking or text overflow issues

### 2. Resolution Settings (Render Resolution)

**Purpose:** Allows users to control the game's rendering resolution for performance and visual quality balance.

**Render Resolution vs Display Resolution:**
- **Render Resolution:** The resolution at which the game is rendered (affects performance and visual quality)
- **Display Resolution:** The physical resolution of the window/screen (set by window mode)
- The framework decouples these two, allowing performance tuning in any window mode

**How It Works:**
- Player selects render resolution (e.g., 1920x1080, 1280x720)
- Game renders at this resolution
- Output is scaled to fit the display
- Lower resolution = better performance, higher resolution = better visual quality

**Available Resolutions:**
- 1920 x 1080 (Full HD)
- 1600 x 900 (HD+)
- 1366 x 768
- 1280 x 720 (HD)
- 1024 x 768

**Usage:**
```gdscript
ConfigManager.set_resolution(Vector2i(1920, 1080))  # Set render resolution
var current_res = ConfigManager.config.resolution   # Get current resolution
```

**Benefits:**
- **Performance Tuning:** Lower resolution improves FPS on lower-end hardware
- **Visual Quality:** Higher resolution provides sharper visuals on capable systems
- **Works in All Modes:** Available in windowed, borderless, and fullscreen modes
- **Automatic Scaling:** Godot handles upscaling/downscaling automatically

### 3. Window Modes

**Purpose:** Provides flexible display options for different user preferences and setups.

**Three Modes:**
- **WINDOWED** - Traditional window where window size matches render resolution
- **BORDERLESS** - Borderless fullscreen at native display resolution (recommended, fast alt-tab)
- **FULLSCREEN** - Exclusive fullscreen mode (better for some older systems)

**Implementation:**
- Resolution setting controls render resolution in all modes
- Windowed mode: window size matches render resolution
- Borderless/Fullscreen modes: display at native resolution, render at selected resolution
- All modes work seamlessly with multi-monitor setups

**Usage:**
```gdscript
ConfigManager.set_window_mode(ConfigManager.WindowMode.BORDERLESS)
```

**Benefits:**
- Borderless mode prevents issues with resolution scaling on modern displays
- Fast switching between windows without minimizing/maximizing delays
- Players can tune performance in any window mode
- OS UI remains accessible (taskbar, system tray, etc.)

### 4. High Contrast Mode

**Purpose:** WCAG AAA compliant theme that automatically converts any custom theme to a high contrast version, or allows developers to provide their own custom high contrast theme.

**Two Approaches for Game Developers:**

The framework provides two flexible approaches for implementing high contrast mode in your game:

#### Approach 1: Provide Your Own Custom High Contrast Theme (Recommended for Full Control)

If you want complete control over the high contrast appearance, you can create your own high contrast theme in the Godot theme editor and provide it to the framework.

**Setup:**
```gdscript
# In your game's initialization (e.g., autoload script or main scene _ready)
func _ready():
	# Set your base theme path (optional, defaults to project.godot setting)
	ConfigManager.base_theme_path = "res://themes/my_game_theme.tres"

	# Provide your custom high contrast theme
	ConfigManager.high_contrast_theme_path = "res://themes/my_game_theme_hc.tres"

	# Framework will use your custom HC theme when user enables high contrast
```

**Benefits:**
- Full artistic control over high contrast appearance
- Can fine-tune every aspect in Godot's theme editor
- Consistent with your game's visual identity
- No surprises - you control exactly how it looks

**Creating Your HC Theme:**
1. Open your base theme in Godot's theme editor
2. Save a copy as `*_hc.tres` (e.g., `my_game_theme_hc.tres`)
3. Adjust colors to meet WCAG AAA standards (7:1 contrast ratio):
   - Use very dark backgrounds (near black)
   - Use very light text (near white)
   - Use saturated, bright accent colors
   - Add visible borders (3-4px white borders recommended)
4. Test with real UI to ensure all elements are clearly visible

#### Approach 2: Automatic Theme Conversion (Recommended for Quick Setup)

If you don't provide a custom high contrast theme, the framework will **automatically generate one** from your base theme using the `ThemeConverter` utility. This is perfect for rapid development and prototyping.

**Setup:**
```gdscript
# In your game's initialization
func _ready():
	# Set your base theme path (optional, defaults to project.godot setting)
	ConfigManager.base_theme_path = "res://themes/my_game_theme.tres"

	# Leave high_contrast_theme_path empty for automatic conversion
	ConfigManager.high_contrast_theme_path = ""  # Empty = auto-convert

	# Framework will auto-generate HC theme when user enables high contrast
```

**How Automatic Conversion Works:**

The `ThemeConverter` analyzes your base theme and applies proven accessibility transformations:

- **Background colors:** Darkened towards black while preserving hue (if desired)
- **Text colors:** Brightened towards white for maximum readability
- **Accent colors:** Saturation boosted to 100%, brightness increased
- **Borders:** Made white with increased width (3-4px)
- **Contrast ratios:** Automatically adjusted to meet WCAG AAA (7:1 minimum)
- **StyleBoxFlat resources:** Generated for panels and buttons with visible borders

**Automatic Conversion Features:**
- Analyzes color luminance to determine role (background/foreground/accent)
- Maintains hue relationships to preserve theme identity
- Ensures minimum 7:1 contrast ratio (WCAG AAA standard)
- Preserves "feel" of original theme while maximizing visibility
- Creates complete Theme resource with proper StyleBoxFlat backgrounds
- Runtime theme switching without scene reload
- Persisted in user config file

**Implementation Details:**
```gdscript
# Automatic conversion in ConfigManager
var converter := ThemeConverter.new()
var hc_text := converter.to_high_contrast_foreground(ThemeColors.TEXT_PRIMARY, false)
var hc_primary := converter.to_high_contrast_accent(ThemeColors.PRIMARY)
var hc_bg := converter.to_high_contrast_background(ThemeColors.BG_DARK, false)

# Creates complete Theme resource with:
# - High contrast colors for all control types (Button, Label, CheckButton, OptionButton)
# - StyleBoxFlat for panels with 3px white borders
# - Complete button styling (normal, hover, pressed, focus states)

# Verify contrast ratio
var ratio := converter.calculate_contrast_ratio(hc_text, hc_bg)
# Result: 21:1 (maximum possible contrast)
```

**For Advanced Users - Manual Palette Conversion:**

You can also use `ThemeConverter` directly for converting color palettes:

```gdscript
# Define your custom palette
var your_palette = {
	"primary": Color(0.8, 0.2, 0.4),      # Your brand color
	"bg_dark": Color(0.1, 0.1, 0.15),    # Your background
	"text": Color(0.9, 0.9, 0.9),         # Your text color
	"success": Color(0.3, 0.7, 0.3),     # Your success color
	"error": Color(0.9, 0.2, 0.2)        # Your error color
}

# Automatically convert to high contrast
var converter := ThemeConverter.new()
var hc_palette := converter.convert_palette(your_palette)

# The converter automatically:
# - Makes backgrounds darker (towards black)
# - Makes text brighter (towards white)
# - Saturates accent colors (100% saturation)
# - Ensures 7:1 contrast ratio
# - Preserves your color relationships

# Access converted colors
var hc_primary = hc_palette["primary"]     # Bright, saturated version
var hc_bg = hc_palette["bg_dark"]          # Very dark version
var hc_text = hc_palette["text"]           # Pure or near-white

# Apply to your UI elements
your_label.add_theme_color_override("font_color", hc_text)
your_panel.add_theme_style_override("panel", create_hc_panel_style(hc_bg))
```

#### Best Practices for Both Approaches

**Working with Godot's Theme Editor:**
- Use consistent naming for theme properties (helps automatic conversion)
- Test both normal and high contrast themes at different UI scales
- Include proper StyleBoxFlat resources with borders (not just colors)
- Define colors for all control states (normal, hover, pressed, focus, disabled)

**Color Contrast Guidelines:**
- Normal text: 7:1 minimum (WCAG AAA)
- Large text (18pt+): 4.5:1 minimum (WCAG AAA)
- Interactive elements: 3:1 minimum against background
- Use `ThemeConverter.calculate_contrast_ratio()` to verify

**Usage in Game Code:**
```gdscript
# Enable/disable high contrast (works with either approach)
ConfigManager.set_high_contrast(true)  # Enable high contrast
var is_enabled = ConfigManager.config.high_contrast  # Check status

# Subscribe to changes
EventBus.subscribe("high_contrast_changed", _on_high_contrast_changed)

func _on_high_contrast_changed(data: Dictionary):
	var enabled = data.enabled
	print("High contrast mode: %s" % ("enabled" if enabled else "disabled"))
```

**Benefits:**
- **Approach 1 (Custom):** Full artistic control, pixel-perfect design, no surprises
- **Approach 2 (Automatic):** Zero setup time, instant accessibility, automatically WCAG AAA compliant
- **Both:** Runtime theme switching, config persistence, EventBus integration
- Dramatically improved visibility for users with low vision
- Better for users with color blindness
- Reduced eye strain in low-light conditions

**ThemeConverter API:**
```gdscript
# Auto-determine conversion (based on luminance)
ThemeConverter.to_high_contrast(color, preserve_hue)

# Specific conversions
ThemeConverter.to_high_contrast_background(color, preserve_hue)  # Dark
ThemeConverter.to_high_contrast_foreground(color, preserve_hue)  # Light
ThemeConverter.to_high_contrast_accent(color)                    # Saturated

# Batch conversion
ThemeConverter.convert_palette(palette_dictionary)

# Contrast validation
ThemeConverter.calculate_contrast_ratio(color1, color2)         # Returns ratio
ThemeConverter.meets_wcag_aaa(foreground, background)           # Returns bool
ThemeConverter.adjust_for_contrast(fg, bg, target_ratio)        # Auto-adjust
```

## User Controls

All accessibility features are accessible from the main menu:
1. Press "Options" on main menu
2. Navigate to "Graphics" tab
3. Adjust settings:
   - Window Mode dropdown (Windowed/Borderless/Fullscreen)
   - Resolution dropdown (render resolution, available in all modes)
   - UI Scale slider (0.8 - 1.5)
   - High Contrast Mode checkbox

## EventBus Integration

All accessibility settings emit events when changed:

```gdscript
# Subscribe to UI scale changes
EventBus.subscribe("ui_scale_changed", _on_ui_scale_changed)

# Subscribe to high contrast changes
EventBus.subscribe("high_contrast_changed", _on_high_contrast_changed)

# Unsubscribe when done
EventBus.unsubscribe("ui_scale_changed", _on_ui_scale_changed)
EventBus.unsubscribe("high_contrast_changed", _on_high_contrast_changed)
```

Event payloads:
- `ui_scale_changed`: `{"scale": float}` - New UI scale value
- `high_contrast_changed`: `{"enabled": bool}` - New high contrast state

## Configuration File

All settings are automatically saved to `user://config.cfg`:

```ini
[display]
resolution_x = 1920
resolution_y = 1080
window_mode = 1  # BORDERLESS
ui_scale = 1.0

[accessibility]
high_contrast = false
```

## Best Practices for Developers

### 1. Respect UI Scale

The UI scale is applied automatically to the root viewport. No special handling needed in most cases.

**Do:**
- Use standard Godot Control nodes and layouts
- Let the framework handle scaling automatically
- Test your UI at 0.8x, 1.0x, and 1.5x scales

**Don't:**
- Hardcode pixel sizes that don't scale
- Use absolute positioning excessively
- Create custom scaling systems

### 2. Design for High Contrast

When creating custom UI elements or themes:

**Do:**
- Use high contrast ratios (at least 4.5:1 for normal text, 7:1 for AAA)
- Provide clear borders and visual separation
- Use both color AND shape/position to convey information
- Test with high contrast mode enabled

**Don't:**
- Rely solely on color to convey meaning
- Use low-contrast color combinations
- Use transparency as the only differentiation

### 3. Test Accessibility Features

Always test new UI with:
- Different UI scales (0.8x, 1.0x, 1.5x)
- All three window modes
- High contrast mode enabled
- Different resolutions

### 4. Keyboard Navigation

Consider adding keyboard navigation support:
- Tab order for UI elements
- Enter/Space for activation
- Arrow keys for navigation
- Esc for cancel/back

## Testing

The framework includes comprehensive tests for all accessibility features:

```bash
# Run all tests (includes accessibility tests)
docker-compose run --rm test
```

Test coverage includes:
- UI scale range validation (test_main_menu.gd:270)
- Window mode switching (test_main_menu.gd:119)
- Resolution visibility logic (test_main_menu.gd:142)
- High contrast toggling (test_main_menu.gd:253)
- Config persistence
- EventBus notifications

## Future Enhancements

Potential accessibility improvements for future versions:

1. **Additional UI Scales:** Consider extending range to 0.5x - 2.0x if needed
2. **Colorblind Modes:** Separate palettes for different types of color blindness
3. **Screen Reader Support:** Integration with OS screen readers
4. **Dyslexia-Friendly Font:** OpenDyslexic or similar fonts as an option
5. **Audio Cues:** Sound effects for UI interactions and important events
6. **Motion Reduction:** Option to disable animations and screen shake
7. **Closed Captions:** For all audio/dialog content
8. **Remappable Controls:** Allow users to customize all keyboard/gamepad inputs

## Standards Compliance

The framework follows these accessibility standards:

- **WCAG 2.1 Level AAA:** High contrast mode meets or exceeds color contrast requirements
- **WCAG 2.1 Level AA:** Standard theme meets minimum contrast requirements
- **Responsive Design:** UI scales proportionally without breaking layouts
- **Platform Standards:** Follows Godot best practices for UI accessibility

## Resources

- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Godot Accessibility Documentation](https://docs.godotengine.org/)
- [Game Accessibility Guidelines](https://gameaccessibilityguidelines.com/)
- [AbleGamers Foundation](https://ablegamers.org/)

## Support

For accessibility issues or feature requests, please file an issue on the project's GitHub repository.
