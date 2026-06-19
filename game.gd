extends Node


signal launch(power: float, angle: float)


func reset_game() -> void:
	get_tree().reload_current_scene()


func clash() -> void:
	var cam := get_tree().root.get_camera_2d()
	var def_zoom := cam.zoom
	var tween := create_tween()
	tween.tween_property(cam, "zoom", Vector2.ONE, 0.1)
	tween.set_ignore_time_scale(true)
	Engine.time_scale = 0.0
	get_tree().create_timer(0.4, true, true, true).timeout.connect(
			_unclash.bind(cam, def_zoom))


func _unclash(camera: Camera2D, default_zoom: Vector2) -> void:
	Engine.time_scale = 1.0
	var tween := create_tween()
	tween.tween_property(camera, "zoom", default_zoom, 0.1)
