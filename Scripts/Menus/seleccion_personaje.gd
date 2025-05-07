extends Control

@onready var vbox_seleccion_1: VBoxContainer = $Panel/MarginContainer/vbox_seleccion_1
@onready var vbox_seleccion_2: VBoxContainer = $Panel/MarginContainer/vbox_seleccion_2
@onready var h_slider: HSlider = $Panel/MarginContainer/vbox_seleccion_1/HBoxContainer/HSlider
var num_jugadores : int = 1
var mapa : String = 'mapa1'
var num_rondas = 1

func _on_ready() -> void:
	h_slider.grab_focus()
	vbox_seleccion_1.show()
	vbox_seleccion_2.hide()

func _on_continuar_pressed() -> void:
	if vbox_seleccion_1.is_visible_in_tree():
		vbox_seleccion_1.hide()
		vbox_seleccion_2.show()
	elif vbox_seleccion_2.is_visible_in_tree():
		get_tree().change_scene_to_file("res://Scenes/main.tscn") # cambiar cuando tengamos mas mapas

func _on_atras_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")

func _on_h_slider_value_changed(value: float) -> void:
	# cuando se cambia el valor del slider lo guardamos
	num_jugadores = value

func _on_button_mapa_item_selected(index: int) -> void:
	match index:
		0:
			mapa = 'mapa1'
		1:
			mapa = 'mapa2'

func _on_button_rondas_item_selected(index: int) -> void:
	match index:
		0:
			num_rondas = 1
		1:
			num_rondas = 2
		2: 
			num_rondas = 4
		3: 
			num_rondas = 8
	
