extends Node2D

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

func _ready():
	crear_jugadores()

func crear_jugadores():
	rondas_ganadas.clear()
	jugadores.clear()

	for i in range(1, SeleccionPersonaje.num_jugadores + 1):
		var player = PlayerScene.instantiate()
		player.player_id = i
		player.position = Vector2(i * 30, 0)
		add_child(player)
		jugadores.append(player)
		rondas_ganadas[i] = 0
		if i>1:
			player.get_node("Sprite2D").modulate = colores[i]

func _process(delta: float) -> void:
	var vivos = jugadores.filter(func(p): return p.HP > 0)

	if vivos.size() == 1:
		var ganador_id = vivos[0].player_id
		rondas_ganadas[ganador_id] += 1
		rondas_jugadas += 1

		print("Jugador ", ganador_id, " gana la ronda. Total:", rondas_ganadas[ganador_id])

		if rondas_jugadas >= SeleccionPersonaje.num_rondas:
			print("Fin del juego.")
			mostrar_resultado_final()
		else:
			resetear_ronda()

func resetear_ronda():
	for p in jugadores:
		p.queue_free()

	await get_tree().create_timer(1.0).timeout
	crear_jugadores()

func mostrar_resultado_final():
	var ganador_final = rondas_ganadas.keys()[0]
	var max_puntos = rondas_ganadas[ganador_final]

	for id in rondas_ganadas.keys():
		if rondas_ganadas[id] > max_puntos:
			max_puntos = rondas_ganadas[id]
			ganador_final = id

	print("Jugador ganador final: ", ganador_final)

	# Reiniciar o cambiar de escena si quieres
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")

		
	
