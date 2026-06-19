extends Control

func _ready():
	%RestartButton.pressed.connect(_restart)
	%ShopButton.pressed.connect(_goto_shop)

func _restart() -> void:
	get_tree().paused = false
	Game.reset_game()
	
	
func _goto_shop():
	Game.enter_shop()
