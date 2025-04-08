extends Node2D

var PlayerScene = preload("res://Scenes/player.tscn")

func _ready():
	var player1 = PlayerScene.instantiate()
	player1.player_id = 1
	player1.position = Vector2(0, -50)
	add_child(player1)

	var player2 = PlayerScene.instantiate()
	player2.player_id = 2
	player2.position = player1.position + Vector2(50, 0)
	add_child(player2)

	# Cambiar color del sprite de player2
	var sprite2 = player2.get_node("Sprite2D")
	sprite2.modulate = Color(0.5, 0.7, 1.0)  # Azul clarito, tú puedes ajustar el color que quieras
