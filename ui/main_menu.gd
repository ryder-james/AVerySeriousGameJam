extends Node2D

func _ready():
	%Start.pressed.connect(_start)
	%Settings.pressed.connect(_show_settings.bind(true))
	%ClearSave.pressed.connect(func() -> void:
			_show_settings(false)
			_show_are_you_sure(true)
	)
	%Back.pressed.connect(_show_settings.bind(false))
	%Yes.pressed.connect(_clear_save)
	%No.pressed.connect(func() -> void:
			_show_settings(true)
			_show_are_you_sure(false)
	)

func _start() -> void:
	Game.goto_game()
	
	
func _show_settings(show_settings: bool):
	%MainButtons.visible = not show_settings
	%SettingsContainer.visible = show_settings


func _show_are_you_sure(show_are_you_sure: bool) -> void:
	%SettingsContainer.visible = not show_are_you_sure
	%AreYouSurePopup.visible = show_are_you_sure


func _clear_save() -> void:
	Game.clear_save()
	_show_are_you_sure(false)
	_show_settings(true)
