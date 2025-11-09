# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Boz Godot Framework** is a professional Godot 4.5 framework configured with GL Compatibility rendering. The project provides a robust foundation for game development with comprehensive systems including localization, event management, tooltips, and file handling.

**Development Approach:** This project follows Test-Driven Development (TDD) principles. All systems should have basic tests written upon implementation to ensure functionality and prevent regressions.

## Project Structure

- `scenes/` - Godot scene files (.tscn)
  - `main_menu.tscn` - Main entry point (set as main scene in project.godot)
  - `game.tscn` - Game scene with navigation back to main menu
- `scripts/` - GDScript files (.gd)
  - `main_menu.gd` - Controls Start/Options/Quit buttons and language selection
  - `game.gd` - Game scene controller with back navigation
  - `file_manager.gd` - Singleton for filesystem abstraction (console-ready)
  - `config_manager.gd` - Singleton for game settings persistence
  - `localization_manager.gd` - Singleton for language management
  - `tooltip_manager.gd` - Singleton for dynamic tooltip system
  - `event_bus.gd` - Singleton for global event management
  - `editor_tools/` - Editor-only scripts for setup and maintenance (not game logic)
    - `setup_base_theme.gd` - Generates base_theme.tres with framework defaults
  - `theme/` - Theme system classes
    - `theme_colors.gd` - Color palette constants and utilities
    - `theme_constants.gd` - Spacing, sizing, and layout constants
  - `utils/` - Utility classes with static helper functions
    - `time_utils.gd` - Time formatting and manipulation utilities
- `themes/` - Godot theme resources (.tres)
  - `fonts/` - Font resources (header, body, ui)
  - `base_theme.tres` - Main comprehensive theme (to be created)
  - `main_menu.tres` - Legacy theme (being phased out)
- `translations/` - Localization files (GNU gettext PO format)
  - `messages.pot` - Translation template file
  - `messages.{en,de,hu,ja}.po` - Language-specific translation files
- `tests/` - Automated test files using GUT framework
- `docs/` - Documentation files
  - `theme_system.md` - Comprehensive theme system documentation
  - `event_architecture.md` - Event system architecture guide
  - `localization_platform_integration.md` - Guide for translation platforms (Weblate, Crowdin, etc.)
  - `code_formatting.md` - Code formatting guidelines and VSCode setup
- `Dockerfile` - Docker image definition for headless testing
- `docker-compose.yml` - Docker services: test, validate, shell

## Scene Navigation

The project uses `get_tree().change_scene_to_file()` for scene transitions:

- Main menu → Game: `res://scenes/game.tscn` (scripts/main_menu.gd:16)
- Game → Main menu: `res://scenes/main_menu.tscn` (scripts/game.gd:4)

## Core Systems

### FileManager (scripts/file_manager.gd)

Filesystem abstraction layer designed for console compatibility:

- Mount/unmount support for console platforms
- Write queue with auto-flush timer (5 second interval)
- Batched writes to reduce I/O operations
- Config file read/write methods
- Platform detection (currently supports PC, ready for PS/Xbox/Switch)
- Singleton accessible via `FileManager` global

### ConfigManager (scripts/config_manager.gd)

Manages game settings and persists them via FileManager:

- **Window Modes**: Three display modes for PC gaming
  - `WINDOWED` - Traditional windowed mode with custom resolution control
  - `BORDERLESS` - Borderless fullscreen at native resolution (default, recommended for PC gaming)
  - `FULLSCREEN` - Exclusive fullscreen mode
- **Resolution Settings**: 1920x1080, 1600x900, 1366x768, 1280x720, 1024x768 (applies only in windowed mode)
- **UI Scale**: Scales entire interface proportionally (0.8x to 1.5x range for accessibility)
  - Uses `content_scale_factor` to scale viewport/UI tree
  - Affects text, buttons, icons, spacing - everything scales together
- **Backward Compatibility**: Automatically converts old config formats (fullscreen bool → window_mode enum, font_scale → ui_scale)
- Settings stored in `user://config.cfg`
- Auto-loads and applies settings on startup
- Emits `ui_scale_changed` event via EventBus when UI scale changes
- Singleton accessible via `ConfigManager` global

### LocalizationManager (scripts/localization_manager.gd)

Handles multi-language support using Godot's TranslationServer:

- Supports English (en), German (de), Hungarian (hu), and Japanese (ja)
- Auto-detects system language on first run
- Persists language preference via FileManager
- Uses GNU gettext PO format for professional translation workflows
  - Compatible with translation platforms (Weblate, Crowdin, Lokalise, Phrase)
  - Supports CAT tools and translator comments
  - Template file: `messages.pot`, language files: `messages.{en,de,hu,ja}.po`
- Natural source strings (e.g., "Start Game") instead of UPPERCASE_KEYS
- Emits `language_changed` event via EventBus for cross-system updates
- Subscribe with: `EventBus.subscribe("language_changed", callback)`
- Singleton accessible via `LocalizationManager` global

### TooltipManager (scripts/tooltip_manager.gd)

Dynamic tooltip system with advanced features:

- Function-based tooltip content (supports dynamic/state-aware tooltips)
- Automatic size calculation based on content
- Flicker-free updates (uses invisible measurement panel)
- BBCode rich text support
- Localization integration
- Configurable delay and update intervals
- Singleton accessible via `TooltipManager` global

### EventBus (scripts/event_bus.gd)

Centralized event management system for global events:

- Subscribe/unsubscribe to named events
- Priority-based listener ordering
- Event filtering with callbacks
- Debouncing for high-frequency events
- One-shot listeners (auto-remove after first call)
- Event history and statistics for debugging
- Singleton accessible via `EventBus` global

**When to use EventBus vs Direct Signals:**
- **Use EventBus for:** Cross-system communication, game state changes, achievements, analytics
- **Use Direct Signals for:** Parent-child communication, high-frequency events, tightly coupled components
- See `docs/event_architecture.md` for detailed guidelines and examples

## Theme System

Comprehensive theming system for maintaining visual consistency across the entire framework.

### Theme Components

#### ThemeColors (scripts/theme/theme_colors.gd)

Centralized color palette with constants for all UI colors:

- **Primary colors**: Main brand/accent colors (PRIMARY, PRIMARY_HOVER, PRIMARY_PRESSED, PRIMARY_DISABLED)
- **Secondary colors**: Less prominent UI elements
- **Background colors**: Panels and overlays (BG_DARK, BG_MEDIUM, BG_LIGHT, BG_OVERLAY, BG_TRANSPARENT)
- **Text colors**: Text hierarchy (TEXT_PRIMARY, TEXT_SECONDARY, TEXT_TERTIARY, TEXT_DISABLED, TEXT_INVERTED)
- **Status colors**: Feedback states (SUCCESS, WARNING, ERROR, INFO)
- **Border colors**: Outlines and separators
- **Utility functions**: `with_alpha()`, `darken()`, `lighten()`, `blend()`, `get_contrasting_text_color()`

#### ThemeConstants (scripts/theme/theme_constants.gd)

Spacing, sizing, and layout constants:

- **Spacing scale**: SPACING_TINY (4px) through SPACING_HUGE (48px) - based on 8px grid
- **Component sizes**: Button heights, icon sizes, input heights, panel minimums
- **Font sizes**: FONT_SIZE_TINY (10px) through FONT_SIZE_MASSIVE (48px)
- **Borders & corners**: Border widths and corner radius values
- **Animation durations**: Standard timing values (0.1s to 0.8s)
- **Z-index layers**: LAYER_BACKGROUND through LAYER_TOP
- **Responsive breakpoints**: Mobile (640), Tablet (1024), Desktop (1280), Wide (1920)
- **Utility functions**: Responsive helpers, viewport size checks

#### Font Resources (themes/fonts/)

Three font types for different purposes:

- **header.tres**: Bold fonts for titles (weight: 700, size: 32)
- **body.tres**: Regular fonts for body text (weight: 400, size: 14)
- **ui.tres**: Medium fonts for UI elements (weight: 500, size: 14)

See `themes/fonts/SETUP_FONTS.md` for font setup instructions.

#### Base Theme Resource (themes/base_theme.tres)

Main theme resource that styles all Godot Control nodes. Apply globally in project.godot or per-scene.

### Using the Theme System

**In GDScript:**
```gdscript
# Use color constants
var style := StyleBoxFlat.new()
style.bg_color = ThemeColors.BG_DARK
style.border_color = ThemeColors.BORDER
style.corner_radius_all = ThemeConstants.CORNER_RADIUS_MEDIUM

# Use spacing constants
margin.add_theme_constant_override("margin_left", ThemeConstants.SPACING_LARGE)

# Use utility functions
var hover_color := ThemeColors.lighten(ThemeColors.PRIMARY, 0.1)
var semi_transparent := ThemeColors.with_alpha(ThemeColors.BG_DARK, 0.5)
```

**Best Practices:**
- Always use ThemeColors constants instead of hardcoding Color() values
- Use ThemeConstants for all spacing/sizing instead of magic numbers
- Apply base_theme.tres globally or at scene root level
- Use theme_overrides sparingly for exceptions only
- Leverage utility functions for dynamic color adjustments

**Complete documentation:** See `docs/theme_system.md` for comprehensive usage guide, examples, and best practices.

## Localization System

The project uses Godot's built-in localization with **gettext PO files** (industry-standard format):

### File Structure

- `translations/messages.pot` - Template file with source strings (English)
- `translations/messages.en.po` - English translations
- `translations/messages.de.po` - German translations (Deutsch)
- `translations/messages.hu.po` - Hungarian translations (Magyar)
- `translations/messages.ja.po` - Japanese translations (日本語)

### Adding Translatable Text

1. **In scenes (.tscn)**: Set text properties to natural English strings (e.g., `text = "Start Game"`)
2. **In scripts (.gd)**: Use `tr("natural string")` function for dynamic text (e.g., `print(tr("Starting the game!"))`)
3. **Add to PO files**: Update all language-specific .po files with translations for the new string

### Translation Workflow

**Using Natural Source Strings:**
- English text is used as the msgid (source) in PO files
- Translators translate from English to their language
- In English, `tr("Start Game")` returns "Start Game"
- In German, `tr("Start Game")` returns "Spiel starten"

**Editing PO Files:**
- Use professional tools: Poedit, Weblate, Crowdin, Lokalise
- Or edit manually with any text editor
- PO format includes comments for translator context
- Supports plural forms and string formatting

**String Formatting:**
- Use printf-style formatting: `tr("Changing resolution to %dx%d") % [1920, 1080]`
- Result: "Changing resolution to 1920x1080"

**Key Features of Gettext:**
- Context support via `msgctxt` for disambiguating identical strings
- Translator comments via `#.` for providing context
- Fuzzy matching when source strings change
- Compatible with all major localization platforms

### Localization Platform Integration

The framework supports integration with professional localization platforms for large-scale projects:
- **Weblate** - Free/open-source, self-hosted or cloud
- **Crowdin** - Professional CAT tool with free tier
- **Lokalise** - Team collaboration platform
- **Phrase** - Enterprise localization platform

See `docs/localization_platform_integration.md` for setup guides and workflows.

## Testing Framework

This project uses GUT (Godot Unit Test) for automated testing. All core systems should have corresponding test files.

### Test Structure

- `tests/` - Test files directory
  - `test_*.gd` - Test files (extend GutTest)
- `addons/gut/` - GUT testing framework

### Running Tests

**In Godot Editor:**

1. Open the GUT panel (bottom panel tabs)
2. Click "Run All" to execute all tests
3. View results in the panel

**Via Docker:**

The project includes Docker support for headless testing and CI/CD:

```bash
# Run all tests (container auto-removes after completion)
docker-compose run --rm test

# Run project validation (container auto-removes after completion)
docker-compose run --rm validate

# Open interactive shell for debugging (container auto-removes on exit)
docker-compose run --rm shell
```

**Important:** Always use the `--rm` flag to automatically remove containers after they exit. This prevents container buildup.

**Docker Setup:**

- Uses `barichello/godot-ci:4.5` base image
- Tests run via GUT command-line interface (`addons/gut/gut_cmdln.gd`)
- Project mounted at `/workspace` in container
- Headless mode for CI/CD compatibility
- GUT runs with `-gexit` flag to exit cleanly after tests complete
- Containers configured with `restart: "no"` to prevent lingering
- Combined with `--rm` flag, containers auto-remove immediately after tests complete

### Writing Tests

Follow these conventions when writing tests:

1. **File Naming:** `test_<system_name>.gd` (e.g., `test_localization_manager.gd`)

2. **Test Structure:**

```gdscript
extends GutTest

# Setup runs before each test
func before_each():
    # Initialize test fixtures
    pass

# Teardown runs after each test
func after_each():
    # Clean up test fixtures
    pass

# Test functions must start with 'test_'
func test_something():
    assert_eq(actual, expected, "Descriptive message")
```

3. **Common Assertions:**

   - `assert_eq(a, b, msg)` - Assert equal
   - `assert_ne(a, b, msg)` - Assert not equal
   - `assert_true(condition, msg)` - Assert true
   - `assert_false(condition, msg)` - Assert false
   - `assert_not_null(value, msg)` - Assert not null
   - `assert_gt(a, b, msg)` - Assert greater than
   - `assert_signal_emitted(object, signal_name, msg)` - Assert signal was emitted

4. **Testing Singletons:**

   - Access autoload singletons directly: `LocalizationManager`, `ConfigManager`, `FileManager`
   - Remember to restore state in `after_each()` to prevent test pollution

5. **Testing Scenes:**

   - Preload scene: `var scene = preload("res://scenes/main_menu.tscn")`
   - Instantiate: `var instance = scene.instantiate()`
   - Add to tree: `add_child(instance)`
   - Clean up: `instance.queue_free()` in `after_each()`

6. **Async Testing:**
   - Use `await get_tree().process_frame` for operations that need a frame
   - Use `await` for signals or timeouts

### TDD Guidelines

When implementing new features:

1. **Write tests first** (when practical) or **immediately after** implementation
2. **Test core functionality:**
   - Initialization and default states
   - Public API methods
   - Edge cases and error handling
   - Signal emissions
   - State persistence (for systems using FileManager)
3. **Keep tests simple and focused** - one concept per test
4. **Use descriptive test names** - `test_language_change_emits_signal()` not `test_1()`
5. **Don't test implementation details** - test behavior, not internal structure

### Existing Test Coverage

- ✅ `test_game.gd` - Game scene tests
- ✅ `test_main_menu.gd` - Main menu scene and UI tests
- ✅ `test_localization_manager.gd` - Localization system tests

### Test Coverage Targets

All core systems should have tests covering:

- **FileManager:** File operations, mount/unmount, queue/flush, platform detection
- **ConfigManager:** Settings load/save, resolution changes, fullscreen toggle
- **LocalizationManager:** Language switching, translation key lookup, persistence (✅ Implemented)

## Running the Project

This project must be opened and run through the Godot 4.5 editor. Use the editor's play button or F5 to run the project.

## File Editing Notes

- `.tscn` and `.tres` files are Godot's text-based scene/resource format - edit with care as they contain UIDs and node relationships
- The `.godot/` directory contains editor cache and metadata - excluded from git
- GDScript files use tabs for indentation
- Scene connections use signal bindings (e.g., `[connection signal="pressed" from="..." to="..." method="..."]`)
- **When removing/renaming files:** Always handle both `.gd` and `.gd.uid` files together
  - Example: Removing `calculator.gd` also requires removing `calculator.gd.uid`
  - Example: Renaming `old_script.gd` to `new_script.gd` also requires renaming `old_script.gd.uid` to `new_script.gd.uid`
  - UID files track Godot's internal resource IDs and must stay in sync with their corresponding scripts

## Code Formatting

The project uses automatic code formatting for GDScript files to maintain consistency.

### VSCode Setup

The project is configured for automatic formatting in VSCode:

- **Extension Required:** `godot-tools` by geequlim (recommended in `.vscode/extensions.json`)
- **Format on Save:** Enabled (configured in `.vscode/settings.json`)
- **Indentation:** Tabs (4 spaces wide)
- **Line Endings:** LF (Unix-style) - enforced by `.gitattributes` and `.editorconfig`
- **Max Line Length:** 100 characters

### Configuration Files

- `.gdformat` - Formatter configuration (tabs, line length, etc.)
- `.editorconfig` - Editor configuration (line endings, indentation, charset)
- `.gitattributes` - Git configuration (enforces LF line endings on commit)
- `.vscode/settings.json` - VSCode editor settings (format on save, tab size, line endings)
- `.vscode/extensions.json` - Recommended extensions for the project

### Manual Formatting

To format a file manually:

- **Windows/Linux:** `Shift+Alt+F`
- **Mac:** `Shift+Option+F`
- **Command Palette:** "Format Document"

### Formatting Rules

- **Indentation:** Always use tabs (not spaces)
- **Line Endings:** Always use LF (`\n`), never CRLF (`\r\n`)
- **Line Length:** Keep lines under 100 characters when possible
- **Type Hints:** Always include type hints for variables and function parameters
- **Naming:** Follow GDScript conventions (snake_case for functions/variables, PascalCase for classes)

### Line Ending Enforcement

The project enforces LF line endings to prevent Git conflicts:

- **`.gitattributes`** ensures all text files use LF on commit
- **`.editorconfig`** configures editors to use LF
- **`.vscode/settings.json`** sets VSCode to use LF (`files.eol: "\n"`)

See `docs/code_formatting.md` for detailed formatting guidelines and troubleshooting.
