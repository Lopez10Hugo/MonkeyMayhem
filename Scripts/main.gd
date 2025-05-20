extends Node2D

@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var tabla_puntuaciones: VBoxContainer = $Camera2D/tabla_puntuaciones
@onready var mensaje_victoria_ronda: Label = $Camera2D/mensaje_victoria_ronda
@onready var mapa_base: TileMapLayer = $TileMapLayer
@onready var arma_base: Area2D = $WeaponBase
@onready var camara: Camera2D = $Camera2D


var PlayerScene = preload("res://Scenes/player.tscn")
var escena_espada = preload("res://Scenes/Sword.tscn")
var escena_pistola = preload("res://Scenes/pistol.tscn")
var mapa_actual 
var jugadores = []
var rondas_jugadas = 0
var puntos_spawn = []
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
	#camara.current = true
	mapa_actual = mapa_base
	reset = true
	crear_mapa()
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
		
		if i - 1 < puntos_spawn.size():
			player.position = puntos_spawn[i - 1]
		else:
			# Si no hay suficientes puntos de spawn definidos, asignar posición por defecto
			player.position = Vector2(i * 30, 0)
			print("No hay suficiente spawn definido para el jugador ", i, ". Usando posición por defecto.")
		
		add_child(player)
		jugadores.append(player)
		if reset:
			print('reset')
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
		
	handle_camara(delta)
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

	var zoom_min = 1.8  # Cuando los jugadores están lejos, la cámara estará más cerca
	var zoom_max = 1.3  # Cuando los jugadores están cerca, aún más cerca

	var distancia_min = 10.0  # Reducimos para que el zoom se acerque antes
	var distancia_max = 800.0  # Ajustamos el rango para transiciones más suaves

	var t = clamp((max_dist - distancia_min) / (distancia_max - distancia_min), 0, 1)
	var zoom_target = lerp(zoom_min, zoom_max, t)

	var suavizado_zoom = 1.5
	camara.zoom = camara.zoom.lerp(Vector2(zoom_target, zoom_target), suavizado_zoom * delta)


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
	# Eliminar armas actuales
	for arma in get_tree().get_nodes_in_group("armas"):
		arma.queue_free()
	# Volver a cargar armas aleatorias
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
	await get_tree().create_timer(5.0).timeout
	# Reiniciar o cambiar de escena si quieres
	mensaje_victoria_ronda.hide()
	
	#pantalla de carga
	#pantalla_carga.visible = true
	#await get_tree().create_timer(3.0).timeout  # Duración de pantalla de carga
	
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")

func crear_mapa():
	if SeleccionPersonaje.mapa != 'default':
		print("Cargando mapa desde SeleccionPersonaje:", SeleccionPersonaje.mapa)
		var ruta = "res://Scenes/"
		ruta += SeleccionPersonaje.mapa
		ruta += ".tscn"
		print("Cargando mapa: ", ruta)
		cargar_mapa(ruta)
		mapa_base.hide()
		#arma_base.hide()
		cargar_armas()
		#var arma = escena_pistola.instantiate()
		#arma.name = "WeaponBasePistola"  # Asignar un nombre único
		#add_child(arma)
		#print("arma es del tipo: ", arma.get_class())
		#print("arma está en la ruta:", arma.get_path())
#
		#var arma2 = escena_espada.instantiate()
		#arma2.name = "WeaponBaseEspada"  # Asignar un nombre único
		#add_child(arma2)
		#print("arma2 es del tipo: ", arma2.get_class())
		#print("arma2 está en la ruta:", arma2.get_path())
		#
		#print('nodos:')
		#for child in get_tree().get_current_scene().get_children():
			#print(child.name)
	else:
		print("No se especificó un mapa. Usando mapa_base.")
		mapa_base.show()
		arma_base.show()

func cargar_armas() -> void:
	print('cargando armas...')
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
			print('ruta arma', path_arma)
			var arma = load(path_arma).instantiate()
			#arma.add_to_group("armas")
			arma.position = marker.global_position
			arma.name = "WeaponBase" + str(contador)
			add_child(arma)
			contador +=1
			#print('nodos:')
			#for child in get_tree().get_current_scene().get_children():
				#print(child.name)

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
