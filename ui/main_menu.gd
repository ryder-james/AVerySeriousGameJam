extends Node2D

func _ready():
	%Start.pressed.connect(_start)
	%Settings.pressed.connect(_show_settings.bind(true))
	%Back.pressed.connect(_show_settings.bind(false))

func _start() -> void:
	Game.goto_game()
	
	
func _show_settings(show: bool):
	%MainButtons.visible = not show
	%SettingsContainer.visible = show
