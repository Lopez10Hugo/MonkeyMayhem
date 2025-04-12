extends Control

@onready var audio_bus: Label = $HBoxContainer/Audio_bus
@onready var audio_value: Label = $HBoxContainer/audio_value
@onready var h_slider: HSlider = $HBoxContainer/HSlider

@export_enum("Master","Musica","Efectos de sonido") var bus_name : String

var bus_index : int = 0

func _ready() -> void:
	get_bus_name()
	set_label_text_name()
	set_slider_value()

func set_label_text_name():
	audio_bus.text = "Volumen: " + str(bus_name) 

func set_audio_value():
	audio_value.text = str(h_slider.value * 100)

func get_bus_name():
	bus_index = AudioServer.get_bus_index(bus_name)

func set_slider_value():
	h_slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))

func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	set_audio_value()

func _on_focus_entered() -> void:
	print("h slider grabbed focus")
	h_slider.grab_focus()
