extends Node


enum ClashResult {
	UNCALCULATED,
	PLAYER_LOSS,
	PLAYER_VICTORY,
	PLAYER_SUPER_VICTORY,
}

@warning_ignore("unused_signal")
signal player_set(player: Beyblade)
@warning_ignore("unused_signal")
signal launch(power: float, angle: float)
signal end_run()
signal clash(player: RPMAgent, enemy: RPMAgent, result: ClashResult)

var camera: Camera2D
var default_camera_zoom := Vector2.ZERO
var monies : int = 150
var player_distance : int = 0
var distance_record : int = 0
var player: Beyblade = null:
	set = set_player

var upgrade_purchase_counts: Dictionary = {}

var upgrade_values: Dictionary = {
	"center": 1.0,
	"ring": 0.0,
	"rim": 1.0,
	"initial_speed": 100.0,
	"initial_spin": 1.0,
}

func reset_game() -> void:
	reload_game_vars()
	get_tree().reload_current_scene()


func enter_shop():
	reload_game_vars()
	get_tree().change_scene_to_file("res://ui/shop_menu.tscn")


func goto_game():
	reload_game_vars()
	get_tree().change_scene_to_file("res://map.tscn")

func reload_game_vars() -> void:
	player_distance = 0
	Engine.time_scale = 1.0

func calc_monies():
	if player_distance > distance_record:
		monies += player_distance - distance_record
		distance_record = player_distance
	monies += roundi(player_distance/10)

func start_clash(player_rpm: RPMAgent, enemy_rpm: RPMAgent) -> void:
	var clash_result := calculate_clash_results(player_rpm, enemy_rpm)
	if clash_result == ClashResult.PLAYER_SUPER_VICTORY:
		_do_clash(enemy_rpm)
	clash.emit(player_rpm, enemy_rpm, clash_result)


func calculate_clash_results(player_rpm: RPMAgent, enemy_rpm: RPMAgent) -> ClashResult:
	var victory_chance: float = (player_rpm.rpm * get_upgrade_value("rim")) / enemy_rpm.rpm
	if player_rpm.parent_rb.is_dash_invulnerable:
		victory_chance = (player_rpm.rpm * get_upgrade_value("rim") * 2) / enemy_rpm.rpm
	if victory_chance >= 2:
		monies += 100
		return ClashResult.PLAYER_SUPER_VICTORY
	elif victory_chance >= 1:
		monies += 50
		return ClashResult.PLAYER_VICTORY
	else:
		var victory_roll: float = randf()
		if victory_roll <= victory_chance:
			monies += 25
			return ClashResult.PLAYER_VICTORY
	return ClashResult.PLAYER_LOSS


func set_player(new_player: Beyblade) -> void:
	if player:
		player.die.disconnect(_on_player_died)
		player.dash_start.disconnect(_on_dash_started)
		player.dash_end.disconnect(_on_dash_ended)
	player = new_player
	if player:
		player.die.connect(_on_player_died)
		player.dash_start.connect(_on_dash_started)
		player.dash_end.connect(_on_dash_ended)
		camera = get_tree().root.get_camera_2d()
		default_camera_zoom = camera.zoom
		player_set.emit(player)


func _on_player_died() -> void:
	calc_monies()
	player.get_node("%EndRunMenu").visible = true
	end_run.emit()


func _on_dash_started() -> void:
	#Engine.time_scale = 0.25
	#_zoom_in()
	pass


func _on_dash_ended() -> void:
	#Engine.time_scale = 1.0
	#_zoom_out()
	pass


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


func _do_clash(enemy_rpm: RPMAgent) -> void:
	_zoom_in()
	player.shockwave.play()
	get_tree().paused = true
	var enemy = enemy_rpm.parent_rb
	
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_ignore_time_scale(true)
	tween.tween_property(enemy.death_message, "visible_ratio", 1.0, 0.5)
	tween.finished.connect(func() -> void:
			get_tree().create_timer(0.5, true).timeout.connect(
				_unclash.bind(enemy_rpm))
	)


func _unclash(enemy: RPMAgent) -> void:
	get_tree().paused = false
	_zoom_out()
	if clash_result == ClashResult.PLAYER_SUPER_VICTORY:
		enemy.parent_rb.kill()


func purchase_shop_upgrade(upgrade_key: String, cost: int, added_value: float) -> void:
	if monies < cost:
		return

	monies -= cost

	if not upgrade_purchase_counts.has(upgrade_key):
		upgrade_purchase_counts[upgrade_key] = 0

	if not upgrade_values.has(upgrade_key):
		upgrade_values[upgrade_key] = 0.0

	upgrade_purchase_counts[upgrade_key] += 1
	upgrade_values[upgrade_key] += added_value


func get_upgrade_purchase_count(upgrade_key: StringName) -> int:
	return upgrade_purchase_counts.get(upgrade_key, 0)


func get_upgrade_value(upgrade_key: StringName) -> float:
	return upgrade_values.get(upgrade_key, 0.0)


func get_all_upgrade_values() -> Dictionary:
	return upgrade_values.duplicate()
