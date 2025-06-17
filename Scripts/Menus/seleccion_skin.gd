extends Control

@onready var player_labels := [
	$MarginContainer/VBoxContainer/HBoxContainer/Label,
	$MarginContainer/VBoxContainer/HBoxContainer/Label2,
	$MarginContainer/VBoxContainer/HBoxContainer/Label3,
	$MarginContainer/VBoxContainer/HBoxContainer/Label4
]

@onready var player_panels := [
	$MarginContainer/VBoxContainer/HBoxContainer/Label/Panel,
	$MarginContainer/VBoxContainer/HBoxContainer/Label2/Panel2,
	$MarginContainer/VBoxContainer/HBoxContainer/Label3/Panel3,
	$MarginContainer/VBoxContainer/HBoxContainer/Label4/Panel4
]

@onready var player_buttons_izq :=[
	$MarginContainer/VBoxContainer/MarginContainer/HBoxContainer2/izq_1,
	$MarginContainer/VBoxContainer/MarginContainer/HBoxContainer2/izq_2,
	$MarginContainer/VBoxContainer/MarginContainer/HBoxContainer2/izq_3,
	$MarginContainer/VBoxContainer/MarginContainer/HBoxContainer2/izq_4
]
@onready var player_buttons_der :=[
	$MarginContainer/VBoxContainer/MarginContainer/HBoxContainer2/der_1,
	$MarginContainer/VBoxContainer/MarginContainer/HBoxContainer2/der_2,
	$MarginContainer/VBoxContainer/MarginContainer/HBoxContainer2/der_3,
	$MarginContainer/VBoxContainer/MarginContainer/HBoxContainer2/der_4
]

@onready var h_box_container: HBoxContainer = $MarginContainer/VBoxContainer/HBoxContainer

@onready var skin_images := [
	$MarginContainer/VBoxContainer/HBoxContainer/Label/Panel/skin1,
	$MarginContainer/VBoxContainer/HBoxContainer/Label2/Panel2/skin2,
	$MarginContainer/VBoxContainer/HBoxContainer/Label3/Panel3/skin3,
	$MarginContainer/VBoxContainer/HBoxContainer/Label4/Panel4/skin4
]

func set_players(player_count: int) -> void:
	for i in range(player_panels.size()):
		var visible := i < player_count
		player_panels[i].visible = visible
		player_labels[i].visible = visible
		player_buttons_der[i].visible = visible
		player_buttons_izq[i].visible = visible
		
		if visible:
			update_player_skin(i)

	h_box_container.queue_sort()

func _ready() -> void:
	print('numero jugadores: ', SeleccionPersonaje.num_jugadores)
	set_players(SeleccionPersonaje.num_jugadores)  # Cambia este número según la cantidad de jugadores
	_on_focus_entered()
	
	for i in range(SeleccionPersonaje.num_jugadores):
		player_buttons_izq[i].pressed.connect(_on_izq_pressed.bind(i))
		player_buttons_der[i].pressed.connect(_on_der_pressed.bind(i))

@onready var izq_1: Button = $MarginContainer/VBoxContainer/MarginContainer/HBoxContainer2/izq_1
@onready var empezar: Button = $MarginContainer/VBoxContainer/empezar

func _on_focus_entered() -> void:
	izq_1.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://Scenes/Menus/seleccion_personaje.tscn")

func _on_empezar_pressed() -> void:
	SeleccionPersonaje.skins_elegidas.clear()
	for i in range(SeleccionPersonaje.num_jugadores):
		var color_index = player_color_index[i]
		SeleccionPersonaje.skins_elegidas.append(player_colors[color_index])
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_atras_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/seleccion_personaje.tscn")

var player_colors = [0,1,2,3]
var player_color_index = [0, 0, 0, 0]  # Índice del color actual por jugador
var skin_texture_normal = preload("res://Assets/monillo.png")
var skin_texture_rojo = preload("res://Assets/monillo_rojo.png")
var skin_texture_graduado = preload("res://Assets/SpritesMono/mono_graduado_sinfondo.png")
var skin_texture_spiderman = preload("res://Assets/SpritesMono/MonoSpiderman_foto.png")
var skin_textures = [skin_texture_normal,skin_texture_rojo,skin_texture_graduado,skin_texture_spiderman]

func update_player_skin(player_index: int) -> void:
	skin_images[player_index].texture = skin_textures[player_color_index[player_index]]
	#skin_images[player_index].modulate = player_colors[player_color_index[player_index]]

func _on_izq_pressed(player_index: int) -> void:
	player_color_index[player_index] = (player_color_index[player_index] - 1 + player_colors.size()) % player_colors.size()
	update_player_skin(player_index)

func _on_der_pressed(player_index: int) -> void:
	player_color_index[player_index] = (player_color_index[player_index] + 1) % player_colors.size()
	update_player_skin(player_index)
