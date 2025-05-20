class_name Seleccion
extends Node

var num_jugadores = 2
var num_rondas = 1
var mapa = 'default'
var slow_motion_enabled = false
var high_contrast_enabled = false

var armas_disponibles = [
	preload("res://Scenes/Minigun.tscn"),
	preload("res://Scenes/pistol.tscn"),
	#preload("res://Scenes/guided_pistol.tscn"),
	preload("res://Scenes/sword.tscn")
]
