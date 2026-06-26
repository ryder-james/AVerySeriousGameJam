extends Node2D

signal upgrade_purchase_requested(
	upgrade_key: StringName,
	cost: int,
	added_value: float
)


@onready var monies_label: Label = %Monies


var shop_items: Array[ShopItem] = []


func _ready() -> void:
	%GoToGame.pressed.connect(_start)

	upgrade_purchase_requested.connect(Game.purchase_shop_upgrade)

	_cache_shop_items()
	refresh_from_game()


func _start() -> void:
	Game.goto_game()


func _cache_shop_items() -> void:
	shop_items.clear()

	var found_items := find_children("*", "ShopItem", true, false)

	for node in found_items:
		var item := node as ShopItem
		if item == null:
			continue

		shop_items.append(item)

		if not item.purchase_requested.is_connected(_on_shop_item_purchase_requested):
			item.purchase_requested.connect(_on_shop_item_purchase_requested)


func refresh_from_game() -> void:
	for item in shop_items:
		var purchase_count := Game.get_upgrade_purchase_count(item.upgrade_key)
		item.set_purchase_count(purchase_count)
		item.refresh(Game.monies)
		monies_label.text = "Monies: " + str(Game.monies)

func _on_shop_item_purchase_requested(
	upgrade_key: StringName,
	cost: int,
	added_value: float
) -> void:
	upgrade_purchase_requested.emit(
		upgrade_key,
		cost,
		added_value
	)

	refresh_from_game()
