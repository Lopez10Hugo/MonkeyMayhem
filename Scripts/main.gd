extends Node2D

@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var tabla_puntuaciones: VBoxContainer = $Camera2D/tabla_puntuaciones
@onready var mensaje_victoria_ronda: Label = $Camera2D/mensaje_victoria_ronda


var PlayerScene = preload("res://Scenes/player.tscn")
var jugadores = []
var rondas_jugadas = 0
var rondas_ganadas : Dictionary = {}
var colores = [
		Color(1, 0, 0),    # Rojo
		Color(0, 1, 0),    # Verde
		Color(0, 0, 1),    # Azul
		Color(1, 1, 0),    # Amarillo
		Color(1, 0, 1),    # Magenta
		Color(0, 1, 1),    # Cian
		Color(1, 0.5, 0),  # Naranja
		Color(0.6, 0.2, 1) # Violeta
	]
var reset = false
var ronda_en_progreso = true

func _ready():
	print('ready')
	reset = true
	crear_jugadores()
	rondas_ganadas.clear()
	tabla_puntuaciones.show()
	actualizar_marcadores()
	mensaje_victoria_ronda.hide()

func actualizar_marcadores():
	var contenedor = tabla_puntuaciones
	for i in range(1, contenedor.get_child_count()):  # Saltamos el título (index 0)
		var label = contenedor.get_child(i)
		if i <= SeleccionPersonaje.num_jugadores:
			label.visible = true
			var player_id = i
			var puntos = rondas_ganadas.get(player_id, 0)
			label.text = "Jugador %d: %d puntos" % [player_id, puntos]
		else:
			label.visible = false


func crear_jugadores():
	jugadores.clear()

	for i in range(1, SeleccionPersonaje.num_jugadores + 1):
		var player = PlayerScene.instantiate()
		player.player_id = i
		player.position = Vector2(i * 30, 0)
		add_child(player)
		jugadores.append(player)
		if reset:
			print('reset')
			print('i:',i)
			rondas_ganadas[i] = 0
			
		if i>1:
			player.get_node("Sprite2D").modulate = colores[i]
	
	reset = false

func _process(delta: float) -> void:
	if SeleccionPersonaje.high_contrast_enabled:
		print('high contrast enabled')
		canvas_modulate.color = Color(1.5,1.5,1.5)
	else:
		canvas_modulate.color = Color(1,1,1)
	
	if SeleccionPersonaje.slow_motion_enabled:
		print('slow motion enabled')
		Engine.time_scale = 0.5
	else:
		Engine.time_scale = 1.0
		
	if not ronda_en_progreso:
		return
	
	var vivos = jugadores.filter(func(p): return not p.is_dead)

	if vivos.size() == 1:
		ronda_en_progreso = false
		await get_tree().create_timer(1.0).timeout
		var ganador_id = vivos[0].player_id
		print('ganador id:',ganador_id)
		mensaje_victoria_ronda.text = "¡El jugador %d gana la ronda!" % [ganador_id]
		mensaje_victoria_ronda.show()
		await get_tree().create_timer(3.0).timeout
		rondas_ganadas[ganador_id] = rondas_ganadas.get(ganador_id, 0) + 1
		print('rondas ganadas ', rondas_ganadas[ganador_id])
		rondas_jugadas += 1

		print("Jugador ", ganador_id, " gana la ronda. Total:", rondas_ganadas[ganador_id])

		if rondas_jugadas >= SeleccionPersonaje.num_rondas:
			print("Fin del juego.")
			mostrar_resultado_final()
			var reset = true
		else:
			resetear_ronda()

func resetear_ronda():
	for p in jugadores:
		p.queue_free()
	jugadores.clear()

	await get_tree().create_timer(1.0).timeout
	ronda_en_progreso = true
	crear_jugadores()
	reset_armas()
	actualizar_marcadores()
	mensaje_victoria_ronda.hide()

func reset_armas() -> void:
	pass

func mostrar_resultado_final():
	var ganador_final = rondas_ganadas.keys()[0]
	var max_puntos = rondas_ganadas[ganador_final]

	for id in rondas_ganadas.keys():
		if rondas_ganadas[id] > max_puntos:
			max_puntos = rondas_ganadas[id]
			ganador_final = id
	print("Jugador ganador final: ", ganador_final)
	mensaje_victoria_ronda.text = "¡El jugador %d ha ganado la partida!" % [ganador_final]
	mensaje_victoria_ronda.show()
	await get_tree().create_timer(5.0).timeout
	# Reiniciar o cambiar de escena si quieres
	mensaje_victoria_ronda.hide()
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")

		
	
