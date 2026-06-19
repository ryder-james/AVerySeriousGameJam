extends Node


signal launch(power: float, angle: float)


func reset_game() -> void:
	get_tree().reload_current_scene()

func enter_shop():
	get_tree().change_scene_to_file("res://ui/shop_menu.tscn")

func goto_game():
	get_tree().change_scene_to_file("res://map.tscn")
