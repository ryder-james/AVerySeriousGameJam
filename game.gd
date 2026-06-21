extends Node


enum ClashResult {
	UNCALCULATED,
	PLAYER_LOSS,
	PLAYER_VICTORY,
	PLAYER_SUPER_VICTORY,
}

const Beyblade = preload("uid://dvgou34t5mt21")

@warning_ignore("unused_signal")
signal launch(power: float, angle: float)
signal clash(player: RPMAgent, enemy: RPMAgent, result: ClashResult)

var camera: Camera2D
var default_camera_zoom := Vector2.ZERO
var monies : int = 500
var player_distance : int = 0
var player: Beyblade = null:
	set = set_player


func reset_game() -> void:
	player_distance = 0
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()


func enter_shop():
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://ui/shop_menu.tscn")


func goto_game():
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://map.tscn")


func start_clash(player_rpm: RPMAgent, enemy_rpm: RPMAgent) -> void:
	var clash_result := calculate_clash_results(player_rpm, enemy_rpm)
	#_zoom_in()
	#get_tree().paused = true
	#get_tree().create_timer(0.4, true).timeout.connect(
			#_unclash.bind(clash_result, enemy_rpm))
	if clash_result == ClashResult.PLAYER_SUPER_VICTORY:
		enemy_rpm.parent_rb.kill()
	clash.emit(player_rpm, enemy_rpm, clash_result)


func calculate_clash_results(player_rpm: RPMAgent, enemy_rpm: RPMAgent) -> ClashResult:
	var victory_chance: float = player_rpm.rpm / enemy_rpm.rpm
	if victory_chance >= 2 or player_rpm.parent_rb.is_dashing:
		return ClashResult.PLAYER_SUPER_VICTORY
	elif victory_chance >= 1:
		return ClashResult.PLAYER_VICTORY
	else:
		var victory_roll: float = randf()
		if victory_roll <= victory_chance:
			return ClashResult.PLAYER_VICTORY
	return ClashResult.PLAYER_LOSS


func set_player(new_player: Beyblade) -> void:
	if player:
		player.die.disconnect(_on_player_died)
		player.start_dash.disconnect(_on_dash_started)
		player.end_dash.disconnect(_on_dash_ended)
	player = new_player
	if player:
		player.die.connect(_on_player_died)
		player.start_dash.connect(_on_dash_started)
		player.end_dash.connect(_on_dash_ended)
		camera = get_tree().root.get_camera_2d()
		default_camera_zoom = camera.zoom


func _on_player_died() -> void:
	player.get_node("%EndRunMenu").visible = true


func _on_dash_started() -> void:
	Engine.time_scale = 0.25
	_zoom_in()


func _on_dash_ended() -> void:
	Engine.time_scale = 1.0
	_zoom_out()


func _zoom_in(new_zoom := Vector2.ONE) -> void:
	var tween := create_tween()
	tween.tween_property(camera, "zoom", new_zoom, 0.1)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_ignore_time_scale(true)


func _zoom_out() -> void:
	var tween := create_tween()
	tween.tween_property(camera, "zoom", default_camera_zoom, 0.1)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_ignore_time_scale(true)


func _unclash(clash_result: ClashResult, enemy: RPMAgent) -> void:
	get_tree().paused = false
	_zoom_out()
	if clash_result == ClashResult.PLAYER_SUPER_VICTORY:
		enemy.parent_rb.kill()
