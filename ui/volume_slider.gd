@tool
extends HBoxContainer

@export var slider_name: String
@export var bus: StringName


@onready var _label: Label = %Label
@onready var _slider: HSlider = %HSlider
@onready var _num_label: Label = %NumLabel
@onready var _bus_idx: int = AudioServer.get_bus_index(bus)


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_label.text = slider_name
	_slider.value_changed.connect(func(new_value: float) -> void:
			AudioServer.set_bus_volume_linear(_bus_idx, new_value)
			_num_label.text = str(new_value * 100.0)
	)


func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		return
	
	_label.text = slider_name
