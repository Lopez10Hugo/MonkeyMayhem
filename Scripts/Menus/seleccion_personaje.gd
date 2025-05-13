extends Control

@onready var vbox_seleccion_1: VBoxContainer = $Fondo/MarginContainer/vbox_seleccion_1
@onready var h_slider: HSlider = $Fondo/MarginContainer/vbox_seleccion_1/HBoxContainer/HSlider
@onready var jugadores_value: Label = $Fondo/MarginContainer/vbox_seleccion_1/HBoxContainer/jugadores_value
@onready var button_rondas: OptionButton = $Fondo/MarginContainer/vbox_seleccion_1/HBoxContainer3/button_rondas
@onready var button_mapa: OptionButton = $Fondo/MarginContainer/vbox_seleccion_1/HBoxContainer2/button_mapa

func _on_ready() -> void:
	vbox_seleccion_1.show()
	h_slider.value = SeleccionPersonaje.num_jugadores
	set_jugadores_value()
	_on_focus_entered()
	create_buttons()

func _on_focus_entered() -> void:
	print('h_slider grabbed focus')
	h_slider.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")

func _on_continuar_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn") # cambiar cuando tengamos mas mapas

func set_jugadores_value():
	jugadores_value.text = str(h_slider.value)

func _on_atras_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")

func _on_h_slider_value_changed(value: float) -> void:
	# cuando se cambia el valor del slider lo guardamos
	SeleccionPersonaje.num_jugadores = int(value)
	set_jugadores_value()

func _on_button_mapa_item_selected(index: int) -> void:
	match index:
		0:
			SeleccionPersonaje.mapa = 'default'
			print('mapa: ', SeleccionPersonaje.mapa)
		1:
			SeleccionPersonaje.mapa = 'mapa_1'

func _on_button_rondas_item_selected(index: int) -> void:
	match index:
		0:
			SeleccionPersonaje.num_rondas = 1
		1:
			SeleccionPersonaje.num_rondas = 2
		2: 
			SeleccionPersonaje.num_rondas = 4
		3: 
			SeleccionPersonaje.num_rondas = 8

func create_buttons() -> void:
	button_rondas.add_item("1 Ronda")
	button_rondas.add_item("2 Rondas")
	button_rondas.add_item("4 Rondas")
	button_rondas.add_item("8 Ronda")
	
	button_mapa.add_item("Mapa por defecto")
	button_mapa.add_item("Mapa 1: Jungla")
