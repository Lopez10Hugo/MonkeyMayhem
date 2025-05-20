extends Control
@onready var grid_container: GridContainer = $GridContainer
@onready var continuar: Button = $GridContainer/Continuar
@onready var salir: Button = $GridContainer/Salir
#@onready var confirmacion_salir: Window = $"Confirmacion salir"
@onready var confirmacion_salir: Window = $Window
@onready var si_salir: Button = $Window/ColorRect/MarginContainer/VBoxContainer/HBoxContainer/Si
@onready var no_salir: Button = $Window/ColorRect/MarginContainer/VBoxContainer/HBoxContainer/No

var in_confirmacion_salir: bool = false

var in_opciones: bool = false:
	set = set_in_opciones

func _ready() -> void:
	continuar.grab_focus()
	confirmacion_salir.hide()

var pausado : bool = false:
	set = set_pausa

# funcion para reconocer el boton de pausa y el boton de atrás
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pausar"):
		pausado = not pausado
		continuar.grab_focus()
	if event.is_action_pressed("ui_cancel"):
		if in_opciones and pausado:
			in_opciones = false
		elif pausado and not in_opciones:
			pausado = not pausado
		

# setter de pausa
func set_pausa(valor : bool):
	pausado = valor
	get_tree().paused = pausado
	visible = pausado

func set_in_opciones(valor : bool):
	in_opciones = valor
	change_visibilidad_opciones(!in_opciones)

func change_visibilidad_opciones(valor : bool):
#	opciones.visible = valor
	continuar.visible = valor

# funciones para manejar los eventos de los distinos botones:
func _on_continuar_pressed() -> void:
	pausado = false

func _on_opciones_pressed() -> void:
	salir.grab_focus()
	in_opciones = true

func _on_salir_pressed() -> void:
	confirmacion_salir.show()
	in_confirmacion_salir = true
	si_salir.grab_focus()

func _on_si_pressed() -> void:
	pausado = false
	in_confirmacion_salir = false
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")

func _on_no_pressed() -> void:
	in_confirmacion_salir = false
	confirmacion_salir.hide()
	continuar.grab_focus()

# funcion para coger el input cuando el pop up está activo
func _on_confirmacion_salir_window_input(event: InputEvent) -> void:
	if in_confirmacion_salir:
		if event.is_action_pressed("ui_cancel"):
			no_salir.grab_focus()
