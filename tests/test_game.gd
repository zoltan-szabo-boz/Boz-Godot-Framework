extends GutTest

# Test suite for the game scene
# Run via GUT panel in Godot editor or command line

var game_scene = preload("res://scenes/game.tscn")
var game: Node2D

# Setup runs before each test
func before_each():
	game = game_scene.instantiate()
	add_child_autofree(game)

# Teardown runs after each test
func after_each():
	pass  # add_child_autofree handles cleanup automatically

# Test: Game scene loads successfully
func test_game_scene_loads():
	assert_not_null(game, "Game scene should load")
	assert_true(game is Node2D, "Game scene should be a Node2D")

# Test: Game has a back button
func test_game_has_back_button():
	var back_button = game.get_node_or_null("Control/Button")

	assert_not_null(back_button, "Back button should exist in game scene")
	if back_button:
		assert_true(back_button is Button, "Back button should be a Button node")

# Test: Back button has correct text (natural source string)
func test_back_button_text():
	var back_button = game.get_node_or_null("Control/Button")

	if back_button:
		# Button now uses natural source string
		assert_eq(back_button.text, "Back to main menu", "Back button should use natural source string")

# Test: Back button is connected to scene change
func test_back_button_connected():
	var back_button = game.get_node_or_null("Control/Button")

	if back_button:
		var connections = back_button.pressed.get_connections()
		assert_gt(connections.size(), 0, "Back button should have signal connections")

# Test: Game scene has control node
func test_game_has_label():
	var control = game.get_node_or_null("Control")

	assert_not_null(control, "Game scene should have a Control node")
	if control:
		assert_true(control is Control, "Control should be a Control node")
