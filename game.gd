extends Node


signal launch(power: float, angle: float)


func reset_game() -> void:
	get_tree().reload_current_scene()

func enter_shop():
	get_tree().change_scene_to_file("res://ui/shop_menu.tscn")

func goto_game():
	get_tree().change_scene_to_file("res://map.tscn")

func clash() -> void:
	var cam := get_tree().root.get_camera_2d()
	var def_zoom := cam.zoom
	var tween := create_tween()
	tween.tween_property(cam, "zoom", Vector2.ONE, 0.1)
	tween.set_ignore_time_scale(true)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	get_tree().paused = true
	get_tree().create_timer(0.4, true).timeout.connect(
			_unclash.bind(cam, def_zoom))


func _unclash(camera: Camera2D, default_zoom: Vector2) -> void:
	get_tree().paused = false
	var tween := create_tween()
	tween.tween_property(camera, "zoom", default_zoom, 0.1)

