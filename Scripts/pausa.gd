extends Control

var pausado : bool = false:
	set = set_pausa
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pausar"):
		pausado = not pausado

func set_pausa(valor : bool):
	pausado = valor
	get_tree().paused = pausado
	visible = pausado

func _on_continuar_pressed() -> void:
	pausado = false

func _on_opciones_pressed() -> void:
	pass # Replace with function body.

func _on_salir_pressed() -> void:
	pausado = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
