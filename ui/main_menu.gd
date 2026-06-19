extends Node2D

func _ready():
	%Start.pressed.connect(_start)
	%Settings.pressed.connect(_show_settings)

func _start() -> void:
	Game.goto_game()
	
	
func _show_settings():
	#TODO: Make settings sub menu visible, hide other buttons, add settings 
	return
