class_name HighContrastColors
extends RefCounted

## High Contrast Color Palette
##
## WCAG AAA compliant color palette for accessibility.
## Designed for maximum contrast and readability for users with visual impairments.
##
## Key features:
## - Pure black/white for maximum contrast (21:1 ratio)
## - Bright, saturated accent colors for clear differentiation
## - Strong borders (3px minimum) for better visual separation
## - No transparency for crisp edges
##
## Contrast ratios meet or exceed WCAG AAA standards (7:1 for normal text, 4.5:1 for large)

# ============================================================================
# PRIMARY COLORS
# ============================================================================

## High contrast primary color - bright blue for maximum visibility
const PRIMARY: Color = Color(0.0, 0.7, 1.0, 1.0) # Bright cyan-blue

## Primary color on hover state - even brighter
const PRIMARY_HOVER: Color = Color(0.2, 0.8, 1.0, 1.0)

## Primary color on pressed/active state - slightly darker but still vivid
const PRIMARY_PRESSED: Color = Color(0.0, 0.6, 0.9, 1.0)

## Primary color for disabled state - desaturated but still visible
const PRIMARY_DISABLED: Color = Color(0.4, 0.6, 0.7, 1.0)

# ============================================================================
# SECONDARY COLORS
# ============================================================================

## Secondary UI color - bright gray for clear visibility
const SECONDARY: Color = Color(0.7, 0.7, 0.7, 1.0)

## Secondary color on hover state
const SECONDARY_HOVER: Color = Color(0.85, 0.85, 0.85, 1.0)

## Secondary color on pressed/active state
const SECONDARY_PRESSED: Color = Color(0.6, 0.6, 0.6, 1.0)

## Secondary color for disabled state
const SECONDARY_DISABLED: Color = Color(0.5, 0.5, 0.5, 1.0)

# ============================================================================
# BACKGROUND COLORS
# ============================================================================

## Pure black background - maximum contrast
const BG_DARK: Color = Color(0.0, 0.0, 0.0, 1.0)

## Very dark gray - for layered panels
const BG_MEDIUM: Color = Color(0.1, 0.1, 0.1, 1.0)

## Dark gray - for elevated elements
const BG_LIGHT: Color = Color(0.2, 0.2, 0.2, 1.0)

## Pure black - for modals and overlays
const BG_OVERLAY: Color = Color(0.0, 0.0, 0.0, 1.0)

## No transparency in high contrast mode - use solid black
const BG_TRANSPARENT: Color = Color(0.0, 0.0, 0.0, 1.0)

# ============================================================================
# TEXT COLORS
# ============================================================================

## Pure white text - maximum contrast on dark backgrounds
const TEXT_PRIMARY: Color = Color(1.0, 1.0, 1.0, 1.0)

## Bright gray - still highly visible
const TEXT_SECONDARY: Color = Color(0.9, 0.9, 0.9, 1.0)

## Medium gray - for less critical text but still readable
const TEXT_TERTIARY: Color = Color(0.7, 0.7, 0.7, 1.0)

## Disabled text - clearly different but still legible
const TEXT_DISABLED: Color = Color(0.5, 0.5, 0.5, 1.0)

## Pure black - for light backgrounds
const TEXT_INVERTED: Color = Color(0.0, 0.0, 0.0, 1.0)

# ============================================================================
# STATUS COLORS
# ============================================================================

## Bright green for success - high saturation for visibility
const SUCCESS: Color = Color(0.0, 1.0, 0.3, 1.0)

## Success hover state
const SUCCESS_HOVER: Color = Color(0.2, 1.0, 0.4, 1.0)

## Bright yellow for warnings - unmistakable
const WARNING: Color = Color(1.0, 0.9, 0.0, 1.0)

## Warning hover state
const WARNING_HOVER: Color = Color(1.0, 0.95, 0.2, 1.0)

## Bright red for errors - clear danger indication
const ERROR: Color = Color(1.0, 0.2, 0.2, 1.0)

## Error hover state
const ERROR_HOVER: Color = Color(1.0, 0.3, 0.3, 1.0)

## Bright cyan for info
const INFO: Color = Color(0.3, 0.9, 1.0, 1.0)

## Info hover state
const INFO_HOVER: Color = Color(0.4, 0.95, 1.0, 1.0)

# ============================================================================
# BORDER COLORS
# ============================================================================

## White borders for maximum visibility
const BORDER: Color = Color(1.0, 1.0, 1.0, 1.0)

## Bright border on hover
const BORDER_HOVER: Color = Color(1.0, 1.0, 1.0, 1.0) /

## Bright blue border on focus - clearly indicates focus state
const BORDER_FOCUS: Color = Color(0.0, 0.7, 1.0, 1.0)

## Medium gray border for subtle separation
const BORDER_SUBTLE: Color = Color(0.6, 0.6, 0.6, 1.0)

# ============================================================================
# BORDER WIDTHS
# ============================================================================

## High contrast mode uses thicker borders for better visibility
const BORDER_WIDTH_STANDARD: int = 3
const BORDER_WIDTH_FOCUS: int = 4
const BORDER_WIDTH_SUBTLE: int = 2
