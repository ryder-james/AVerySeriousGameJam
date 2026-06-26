extends HBoxContainer
class_name ShopItem


signal purchase_requested(
	upgrade_key: String,
	cost: int,
	added_value: float
)


@export_category("Upgrade Identity")
@export var upgrade_key: String = "rim"
@export var display_name: String = "Upgrade Name"
@export_multiline var description: String = "Upgrade description."
@export var icon_texture: Texture2D


@export_category("Value Scaling")
@export var initial_value: float = 20.0
@export var increase_value: float = 5.0
@export var value_multiplier: float = 1.25
@export var value_prefix: String = "+"
@export var value_suffix: String = ""
@export_range(0, 4, 1) var value_decimal_places: int = 0


@export_category("Cost Scaling")
@export var initial_cost: int = 100
@export var cost_multiplier: float = 1.5
@export var cost_suffix: String = " monies"


@export_category("Limits")
@export var max_purchases: int = 10


var purchases: int = 0


@onready var icon_node: TextureRect = %Icon
@onready var name_label: Label = %Name
@onready var desc_label: Label = %Desc
@onready var value_label: Label = %Value
@onready var next_label: Label = %Next
@onready var cost_label: Label = %Cost
@onready var purchase_button: TextureButton = %UpgradeButton


func _ready() -> void:
	purchase_button.pressed.connect(_on_purchase_button_pressed)


func set_purchase_count(amount: int) -> void:
	purchases = clampi(amount, 0, max_purchases)


func refresh(available_money: int) -> void:
	icon_node.texture = icon_texture
	name_label.text = display_name
	desc_label.text = description

	value_label.text = _format_value(get_current_value())

	if is_maxed():
		next_label.text = "MAX"
		cost_label.text = "MAX"
		purchase_button.disabled = true
		return

	var next_added_value := get_next_added_value()
	var next_cost := get_next_cost()

	next_label.text = _format_value(next_added_value)
	cost_label.text = str(next_cost) + cost_suffix

	purchase_button.disabled = available_money < next_cost


func get_current_value() -> float:
	var total := initial_value

	for i in range(purchases):
		total += increase_value * pow(value_multiplier, i)

	return total


func get_next_added_value() -> float:
	if is_maxed():
		return 0.0

	return increase_value * pow(value_multiplier, purchases)


func get_next_cost() -> int:
	if is_maxed():
		return -1

	return int(round(initial_cost * pow(cost_multiplier, purchases)))


func is_maxed() -> bool:
	return purchases >= max_purchases


func _on_purchase_button_pressed() -> void:
	if is_maxed():
		return

	purchase_requested.emit(
		upgrade_key,
		get_next_cost(),
		get_next_added_value()
	)


func _format_value(value: float) -> String:
	var formatted_value: String

	if value_decimal_places <= 0:
		formatted_value = str(int(round(value)))
	else:
		formatted_value = "%.*f" % [value_decimal_places, value]

	return value_prefix + formatted_value + value_suffix
