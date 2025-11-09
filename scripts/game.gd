extends Node2D

func _ready():
	# Apply UI scale when scene loads (already done by ConfigManager, but ensure it's current)
	ConfigManager.apply_ui_scale()

func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
