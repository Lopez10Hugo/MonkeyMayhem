extends Control

@onready var volver_al_menu: Button = $"MarginContainer/VBoxContainer/Volver al menu"
@onready var options_menu: Control = $"."
@onready var tab_ajustes: Control = $MarginContainer/VBoxContainer/Tab_ajustes

signal exit_options

func _ready() -> void:
	# basicamente no ejecuta nada hasta que process sea true
	set_process(false)

func _on_volver_al_menu_pressed() -> void:
	exit_options.emit()
	set_process(false)

func _on_focus_entered() -> void:
	tab_ajustes.grab_focus()
