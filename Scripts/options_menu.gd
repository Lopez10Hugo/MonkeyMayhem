extends Control

@onready var volver_al_menu: Button = $"MarginContainer/VBoxContainer/Volver al menu"
@onready var options_menu: Control = $"."

signal exit_options

func _ready() -> void:
	# basicamente no ejecuta nada hasta que process sea true
	set_process(false)

func _on_volver_al_menu_pressed() -> void:
	exit_options.emit()
	set_process(false)
	
