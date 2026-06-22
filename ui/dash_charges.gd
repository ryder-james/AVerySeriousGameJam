extends VBoxContainer


const DASH_CHARGE_SCENE = preload("uid://qkqpa7huimdn")
const UIDashCharge = preload("uid://dtqhe4pkd4jeq")


var _player: Beyblade
var _charges: Array[UIDashCharge] = []


func _ready() -> void:
	if Game.player:
		_on_player_set(Game.player)
	else:
		Game.player_set.connect(_on_player_set)


func _process(_delta: float) -> void:
	if not _player or _player.dash_charges == _player.max_dash_charges:
		return
	_charges[_player.dash_charges].progress = _player.dash_recharge_progress


func _on_player_set(new_player: Beyblade) -> void:
	if _player:
		for child in get_children():
			child.queue_free()
		_charges.clear()
		_player.dash_start.disconnect(_on_dash)
		_player.dash_instant.disconnect(_on_dash)
		_player.dash_recharge.disconnect(_on_dash_finished_recharge)
	_player = new_player
	if _player:
		for i in _player.max_dash_charges:
			var charge: UIDashCharge = DASH_CHARGE_SCENE.instantiate()
			_charges.push_front(charge)
			add_child(charge)
		_player.dash_start.connect(_on_dash)
		_player.dash_instant.connect(_on_dash)
		_player.dash_recharge.connect(_on_dash_finished_recharge)


func _on_dash() -> void:
	if _player.dash_charges < _player.max_dash_charges:
		_charges[_player.dash_charges].progress = 0.0
	_charges[_player.dash_charges - 1].progress = _player.dash_recharge_progress


func _on_dash_finished_recharge() -> void:
	pass
	#_charges[_player.dash_charges - 1].progress = 1.0
