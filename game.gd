extends Node


signal launch(power: float, angle: float)


func reset_game() -> void:
	get_tree().reload_current_scene()
