extends ProgressBar


var _player: Beyblade


func _ready() -> void:
	if Game.player:
		_on_player_set(Game.player)
	else:
		Game.player_set.connect(_on_player_set)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not _player or not visible:
		return
	
	value = _player.dash_duration / _player.max_dash_duration


func _on_player_set(new_player: Beyblade) -> void:
	if _player:
		_player.dash_start.disconnect(_on_dash_started)
		_player.dash_end.disconnect(_on_dash_ended)
	_player = new_player
	if _player:
		_player.dash_start.connect(_on_dash_started)
		_player.dash_end.connect(_on_dash_ended)


func _on_dash_started() -> void:
	visible = true


func _on_dash_ended() -> void:
	visible = false
