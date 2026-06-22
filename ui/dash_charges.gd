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


func _on_player_set(new_player: Beyblade) -> void:
	if _player:
		for child in get_children():
			child.queue_free()
		_charges.clear()
		_player.dash_start.disconnect(_on_dash)
		_player.dash_recharge.disconnect(_on_dash_recharged)
	_player = new_player
	if _player:
		for i in _player.max_dash_charges:
			var charge: UIDashCharge = DASH_CHARGE_SCENE.instantiate()
			_charges.append(charge)
			add_child(charge)
		_player.dash_start.connect(_on_dash)
		_player.dash_recharge.connect(_on_dash_recharged)


func _on_dash() -> void:
	_charges[_player.dash_charges].deplete()


func _on_dash_recharged() -> void:
	_charges[_player.dash_charges - 1].charge()
