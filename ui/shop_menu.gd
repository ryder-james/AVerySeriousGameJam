extends Node2D

func _ready():
	%GoToGame.pressed.connect(_start)

func _start() -> void:
	Game.goto_game()
	
	
