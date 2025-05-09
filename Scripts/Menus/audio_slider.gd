extends Control

@onready var audio_bus: Label = $HBoxContainer/Audio_bus
@onready var audio_value: Label = $HBoxContainer/audio_value
@onready var h_slider: HSlider = $HBoxContainer/HSlider
@onready var audio_slider_3: Control = $"../audio_slider3"
@onready var botn_atras: Button = $"../Button"

@export_enum("Master","Musica","Efectos de sonido") var bus_name : String

var bus_index : int = 0

func _ready() -> void:
	get_bus_name()
	load_data()
	set_label_text_name()
	set_slider_value()

func load_data() -> void:
	match bus_name:
		"Master":
			_on_h_slider_value_changed(SettingsDataContainer.get_master_volume())
		"Musica":
			_on_h_slider_value_changed(SettingsDataContainer.get_music_volume())
		"Efectos de sonido":
			_on_h_slider_value_changed(SettingsDataContainer.get_effects_volume())

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
	
	match  bus_index:
		0:
			SettingsSignalBus.emit_on_master_sound_set(value)
		1:
			SettingsSignalBus.emit_on_musica_sound_set(value)
		2:
			SettingsSignalBus.emit_on_efectos_sound_set(value)

func _on_focus_entered() -> void:
	print("h slider grabbed focus")
	h_slider.grab_focus()

func call_focus_on_slider():
	audio_slider_3._on_focus_entered()

func _input(event: InputEvent) -> void:
	if audio_slider_3.has_focus():
		if event.is_action_pressed("ui_down"):
			print('unhandled')
			botn_atras.grab_focus()
	if botn_atras.has_focus():
		if event.is_action_pressed("ui_down"):
			call_deferred("_on_focus_entered")
			#print(get_viewport().gui_get_focus_owner())
		if event.is_action_pressed("ui_up"):
			print(get_viewport().gui_get_focus_owner())
			call_deferred("call_focus_on_slider")
