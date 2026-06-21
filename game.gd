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

var monies : int = 500
var player_distance : int = 0
var clash_result := ClashResult.UNCALCULATED
var player: Beyblade = null:
	set = set_player


func reset_game() -> void:
	player_distance = 0
	get_tree().reload_current_scene()


func enter_shop():
	get_tree().change_scene_to_file("res://ui/shop_menu.tscn")


func goto_game():
	get_tree().change_scene_to_file("res://map.tscn")


func clash(player_rpm: RPMAgent, enemy_rpm: RPMAgent) -> void:
	var cam := get_tree().root.get_camera_2d()
	var def_zoom := cam.zoom
	var tween := create_tween()
	tween.tween_property(cam, "zoom", Vector2.ONE, 0.1)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	get_tree().paused = true
	get_tree().create_timer(0.4, true).timeout.connect(
			_unclash.bind(cam, def_zoom))
	clash_result = calculate_clash_results(player_rpm, enemy_rpm)


func calculate_clash_results(player_rpm: RPMAgent, enemy_rpm: RPMAgent) -> ClashResult:
	var victory_chance: float = player_rpm.rpm / enemy_rpm.rpm
	if victory_chance >= 2:
		return ClashResult.PLAYER_SUPER_VICTORY
	elif victory_chance >= 1:
		return ClashResult.PLAYER_VICTORY
	else:
		var victory_roll: float = randf()
		if victory_roll <= victory_chance:
			return ClashResult.PLAYER_VICTORY
	return ClashResult.PLAYER_LOSS


func consume_clash_result(player_rpm: RPMAgent, enemy_rpm: RPMAgent) -> ClashResult:
	if clash_result == ClashResult.UNCALCULATED:
		return calculate_clash_results(player_rpm, enemy_rpm)
	var result: ClashResult = clash_result
	clash_result = ClashResult.UNCALCULATED
	return result


func set_player(new_player: Beyblade) -> void:
	if player:
		player.death.disconnect(_on_player_death)
	player = new_player
	if player:
		player.death.connect(_on_player_death)


func _on_player_death() -> void:
	player.get_node("%EndRunMenu").visible = true


func _unclash(camera: Camera2D, default_zoom: Vector2) -> void:
	get_tree().paused = false
	var tween := create_tween()
	tween.tween_property(camera, "zoom", default_zoom, 0.1)
