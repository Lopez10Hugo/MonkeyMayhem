extends Control

@onready var sonido: TabBar = $TabContainer/Sonido
@onready var graficos: TabBar = $TabContainer/Gráficos
@onready var boton_modo_ventana: Control = $TabContainer/Gráficos/MarginContainer/ScrollContainer/VBoxContainer/boton_modo_ventana
@onready var volver_al_menu: Button = $"../Volver al menu"
@onready var boton_resolucion: Control = $TabContainer/Gráficos/MarginContainer/ScrollContainer/VBoxContainer/boton_resolucion

var focus_iniciado : bool = false

func _ready() -> void:
	boton_modo_ventana.focus_neighbor_top = volver_al_menu.get_path()
	boton_resolucion.focus_neighbor_bottom = volver_al_menu.get_path()

func _on_focus_entered() -> void:
	boton_modo_ventana.grab_focus()
