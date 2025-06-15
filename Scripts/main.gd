extends Node2D

@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var tabla_puntuaciones: VBoxContainer = $Camera2D/tabla_puntuaciones
@onready var mensaje_victoria_ronda: Label = $Camera2D/mensaje_victoria_ronda
@onready var mapa_base: TileMapLayer = $TileMapLayer
#@onready var arma_base: Area2D = $WeaponBase
@onready var camara: Camera2D = $Camera2D

@onready var pantalla_carga: Control = $Pantalla_carga

var PlayerScene = preload("res://Scenes/player.tscn")
var escena_espada = preload("res://Scenes/Sword.tscn")
var escena_pistola = preload("res://Scenes/pistol.tscn")
var mapa_actual 
var jugadores = []
var rondas_jugadas = 0
var puntos_spawn = []
var rondas_ganadas : Dictionary = {}

var reset = false
var ronda_en_progreso = true

@onready var tutorial_1: Label = $Tutorial1
@onready var foto_tutorial_1: Panel = $Tutorial1/Foto_tutorial1
@onready var tutorial_2: Label = $tutorial2
@onready var foto_tutorial_2: Panel = $tutorial2/foto_tutorial2
@onready var tutorial_3: Label = $tutorial3
@onready var foto_tutorial_3: Panel = $tutorial3/foto_tutorial3
@onready var tutorial_4: Label = $tutorial4
@onready var foto_tutorial_4: Panel = $tutorial4/foto_tutorial4
@onready var tutorial_5: Label = $tutorial5
@onready var foto_tutorial_5: Panel = $tutorial5/foto_tutorial5
@onready var tutorial_6: Label = $tutorial6
@onready var foto_tutorial_6: Panel = $tutorial6/foto_tutorial6

var ids_jugadores_ronda : Array = []

func _ready():
	#camara.current = true
	mapa_actual = mapa_base
	reset = true
	crear_mapa()
	crear_jugadores()
	rondas_ganadas.clear()
	tabla_puntuaciones.show()
	actualizar_marcadores()
	mensaje_victoria_ronda.hide()
	poner_pantalla_carga(false,false)

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
		
		if i - 1 < puntos_spawn.size():
			player.position = puntos_spawn[i - 1]
		else:
			# Si no hay suficientes puntos de spawn definidos, asignar posición por defecto
			player.position = Vector2(i * 30, 0)
			print("No hay suficiente spawn definido para el jugador ", i, ". Usando posición por defecto.")
		
		add_child(player)
		jugadores.append(player)
		if reset:
			#print('reset')
			rondas_ganadas[i] = 0
		match SeleccionPersonaje.skins_elegidas[i - 1]:
			0:
				pass
			1:
				player.get_node("Sprite2D").sprite_frames = $Rojo.sprite_frames
			2:
				player.get_node("Sprite2D").sprite_frames = $Graduado.sprite_frames
	reset = false
	
func crear_jugadores_empate():
	jugadores.clear()

	for id in ids_jugadores_ronda:
		var player = PlayerScene.instantiate()
		
		if id < puntos_spawn.size():
			player.position = puntos_spawn[id]
		else:
			# Si no hay suficientes puntos de spawn definidos, asignar posición por defecto
			player.position = Vector2(id * 30, 0)
			print("No hay suficiente spawn definido para el jugador ", id, ". Usando posición por defecto.")
		
		add_child(player)
		jugadores.append(player)
		if reset:
			#print('reset')
			rondas_ganadas[id] = 0
		match SeleccionPersonaje.skins_elegidas[id]:
			0:
				pass
			1:
				player.get_node("Sprite2D").sprite_frames = $Rojo.sprite_frames
			2:
				player.get_node("Sprite2D").sprite_frames = $Graduado.sprite_frames
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
		
	handle_camara(delta)
	var vivos = jugadores.filter(func(p): return not p.is_dead)

	if vivos.size() == 1 and SeleccionPersonaje.mapa != 'default':
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
			var ganadores = obtener_empate()
			if ganadores.size() > 1:
				print("Empate entre jugadores: ", ganadores)
				jugadores = jugadores.filter(func(p): return ganadores.has(p.player_id))
				ids_jugadores_ronda = jugadores.duplicate()
				SeleccionPersonaje.num_jugadores = ganadores.size()
				SeleccionPersonaje.mapa = "mapa_2"  # usa un mapa especial si querés
				rondas_jugadas -= 1  # no contar esta ronda como una "oficial"
				resetear_ronda(true)
			else:
				print("Fin del juego.")
				mostrar_resultado_final()
				var reset = true
		else:
			resetear_ronda(false)

func obtener_empate() -> Array:
	var max_puntos = -1
	var ganadores = []

	for id in rondas_ganadas.keys():
		var puntos = rondas_ganadas[id]
		if puntos > max_puntos:
			max_puntos = puntos
			ganadores = [id]
		elif puntos == max_puntos:
			ganadores.append(id)

	return ganadores

func handle_camara(delta) -> void:
	if jugadores.size() == 0:
		return

	var vivos = jugadores.filter(func(p): return not p.is_dead)
	if vivos.size() == 0:
		return

	# Centro de los jugadores vivos
	var centro = Vector2.ZERO
	for p in vivos:
		centro += p.global_position
	centro /= vivos.size()
	centro += Vector2(0,-50)
	# Suavemente mover la cámara hacia el centro
	var velocidad_suavizado = 3.0
	camara.global_position = camara.global_position.lerp(centro, velocidad_suavizado * delta)

	# Calcular la distancia máxima entre jugadores
	var max_dist = 0.0
	for i in range(vivos.size()):
		for j in range(i + 1, vivos.size()):
			var dist = vivos[i].global_position.distance_to(vivos[j].global_position)
			if dist > max_dist:
				max_dist = dist

	var zoom_min = 1.4  # Cuando los jugadores están lejos, la cámara estará más cerca
	var zoom_max = 1.3  # Cuando los jugadores están cerca, aún más cerca

	var distancia_min = 10.0  # Reducimos para que el zoom se acerque antes
	var distancia_max = 1300.0  # Ajustamos el rango para transiciones más suaves

	var t = clamp((max_dist - distancia_min) / (distancia_max - distancia_min), 0, 1)
	var zoom_target = lerp(zoom_min, zoom_max, t)

	var suavizado_zoom = 1.5
	camara.zoom = camara.zoom.lerp(Vector2(zoom_target, zoom_target), suavizado_zoom * delta)


func resetear_ronda(empate : bool):
	for p in jugadores:
		p.queue_free()
	jugadores.clear()

	await get_tree().create_timer(1.0).timeout
	ronda_en_progreso = true
	if empate or SeleccionPersonaje.mapa == 'aleatorio':
		crear_mapa()
	crear_jugadores()
	reset_armas()
	actualizar_marcadores()
	mensaje_victoria_ronda.hide()
	poner_pantalla_carga(true,empate)

func reset_armas() -> void:
	print('reset_armas')
	# Eliminar armas actuales
	for arma in get_tree().get_nodes_in_group("armas"):
		arma.queue_free()
		print('Borrando arma, ', arma.name)
	# Volver a cargar armas aleatorias
	await get_tree().process_frame
	cargar_armas()

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
	await get_tree().create_timer(4.0).timeout
	# Reiniciar o cambiar de escena si quieres
	mensaje_victoria_ronda.hide()
	
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")

func crear_mapa():
	if SeleccionPersonaje.mapa != 'default' and SeleccionPersonaje.mapa != "aleatorio":
		#print("Cargando mapa desde SeleccionPersonaje:", SeleccionPersonaje.mapa)
		var ruta = "res://Scenes/"
		mostrar_tutoriales(false)
		ruta += SeleccionPersonaje.mapa
		ruta += ".tscn"
		print("Cargando mapa: ", ruta)
		cargar_mapa(ruta)
		if mapa_base != null:
			mapa_base.hide()
		cargar_armas()
	elif SeleccionPersonaje.mapa == 'aleatorio':
		var ruta = "res://Scenes/"
		mostrar_tutoriales(false)
		var mapa_aleatorio = SeleccionPersonaje.mapas_disponibles[randi() % SeleccionPersonaje.mapas_disponibles.size()]
		ruta += mapa_aleatorio
		ruta += ".tscn"
		print("Cargando mapa: ", ruta)
		cargar_mapa(ruta)
		if mapa_base != null:
			mapa_base.hide()
		cargar_armas()
	else:
		print("No se especificó un mapa. Usando mapa_base.")
		mapa_base.show()
		mostrar_tutoriales(true)
		#arma_base.show()

func mostrar_tutoriales(mostrar : bool):
	if mostrar:
		tutorial_1.show()
		foto_tutorial_1.show()
		tabla_puntuaciones.show()
		tutorial_2.show()
		foto_tutorial_2.show()
		tutorial_3.show()
		foto_tutorial_3.show()
		tutorial_4.show()
		foto_tutorial_4.show()
		tutorial_5.show()
		foto_tutorial_5.show()
		tutorial_6.show()
		foto_tutorial_6.show()
	else:
		tutorial_1.hide()
		foto_tutorial_1.hide()
		tabla_puntuaciones.hide()
		tutorial_2.hide()
		foto_tutorial_2.hide()
		tutorial_3.hide()
		foto_tutorial_3.hide()
		tutorial_4.hide()
		foto_tutorial_4.hide()
		tutorial_5.hide()
		foto_tutorial_5.hide()
		tutorial_6.hide()
		foto_tutorial_6.hide()

func cargar_armas() -> void:
	if mapa_actual == null:
		print("No hay mapa cargado.")
		return
	
	var nodo_spawns = mapa_actual.get_node_or_null("Spawns_armas")
	if nodo_spawns == null:
		print("No se encontraron puntos de spawn.")
		return
	var contador = 0
	for marker in nodo_spawns.get_children():
		if marker is Marker2D:
			# Instanciar arma aleatoria
			var path_arma = SeleccionPersonaje.armas_disponibles.pick_random()
			var arma = load(path_arma).instantiate()
			arma.add_to_group("armas")
			arma.position = marker.global_position
			arma.name = "WeaponBase" + str(contador)
			add_child(arma)
			contador +=1

func cargar_mapa(ruta_mapa: String):
	if mapa_actual:
		mapa_actual.queue_free()  # Elimina el mapa anterior
	var nuevo_mapa = load(ruta_mapa).instantiate()
	add_child(nuevo_mapa)
	mapa_actual = nuevo_mapa
	
	puntos_spawn.clear()
	var nodo_spawns = nuevo_mapa.get_node_or_null("Spawns")
	if nodo_spawns:
		for child in nodo_spawns.get_children():
			if child is Marker2D:
				puntos_spawn.append(child.global_position)
	else:
		print("Advertencia: No se encontraron puntos de spawn en el mapa.")

func poner_pantalla_carga(next_round: bool,empate : bool) -> void:
	# Bloquea movimiento
	for jugador in jugadores:
		jugador.puede_moverse = false
	
	pantalla_carga.show()
	print('Cargando...')
	await pantalla_carga.iniciar(next_round,empate)
	pantalla_carga.hide()
	print('Carga terminada')
	# Desbloquea movimiento
	for jugador in jugadores:
		jugador.puede_moverse = true
