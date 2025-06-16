# PantallaCarga.gd
extends Control

@onready var label = $CanvasLayer/fondo/MarginContainer/mensaje
var countdown = 3
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var fondo: Panel = $CanvasLayer/fondo

func iniciar(next_round: bool, empate: bool) -> void:
	mostrar()
	if next_round:
		if empate:
			label.text = 'Un empate...'
			await get_tree().create_timer(1.0).timeout
			label.text = 'Los jugadores serán \ntransportados al mapa\n de desempate...'
			await get_tree().create_timer(2.0).timeout
		await contar_regresivamente()
	else:
		label.text = "Cargando..."
		await get_tree().create_timer(1.0).timeout
	esconder()

func contar_regresivamente():
	print('Cuenta regresiva...')
	for i in countdown:  # i = 0,1,2
		var restante = countdown - i
		label.text = "Próxima ronda en %d..." % restante
		await get_tree().create_timer(1.0).timeout

func esconder():
	hide()
	canvas_layer.hide()
	label.hide()
	fondo.hide()

func mostrar():
	show()
	canvas_layer.show()
	label.show()
	fondo.show()


	
